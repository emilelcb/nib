{nib, ...}:
with builtins;
with nib.types; rec {
  nameValuePair = name: value: {inherit name value;};

  identityAttrs = value: {${value} = value;};

  identityAttrsList = values: map (v: identityAttrs v) values;

  /**
  Generate an attribute set by mapping a function over a list of
  attribute names.

  # Inputs

  `names`

  : Names of values in the resulting attribute set.

  `f`

  : A function, given the name of the attribute, returns the attribute's value.

  # Type

  ```
  genAttrs :: [ String ] -> (String -> Any) -> AttrSet
  ```

  # Examples
  :::{.example}
  ## `lib.attrsets.genAttrs` usage example

  ```nix
  genAttrs [ "foo" "bar" ] (name: "x_" + name)
  => { foo = "x_foo"; bar = "x_bar"; }
  ```

  :::
  */
  genAttrs = names: f: genAttrs' names (n: nameValuePair n (f n));

  /**
  Like `genAttrs`, but allows the name of each attribute to be specified in addition to the value.
  The applied function should return both the new name and value as a `nameValuePair`.
  ::: {.warning}
  In case of attribute name collision the first entry determines the value,
  all subsequent conflicting entries for the same name are silently ignored.
  :::

  # Inputs

  `xs`

  : A list of strings `s` used as generator.

  `f`

  : A function, given a string `s` from the list `xs`, returns a new `nameValuePair`.

  # Type

  ```
  genAttrs' :: [ Any ] -> (Any -> { name :: String; value :: Any; }) -> AttrSet
  ```

  # Examples
  :::{.example}
  ## `lib.attrsets.genAttrs'` usage example

  ```nix
  genAttrs' [ "foo" "bar" ] (s: nameValuePair ("x_" + s) ("y_" + s))
  => { x_foo = "y_foo"; x_bar = "y_bar"; }
  ```

  :::
  */
  genAttrs' = xs: f: listToAttrs (map f xs);

  mapAttrsRecursiveCond = cond: f: set: let
    recurse = path:
      mapAttrs (
        name: value: let
          next = path ++ [name];
        in
          if isAttrs value && cond value
          then recurse next value
          else f next value
      );
  in
    recurse [] set;

  mapAttrsRecursive = f: set: mapAttrsRecursiveCond (as: true) f set;

  # form: attrValueAt :: xs -> path -> value
  # given path as a list of strings, return that value of an
  # attribute set at that path
  attrValueAt = foldl (l: r:
    if l != null && hasAttr r l
    then l.${r}
    else null);

  mergeAttrsList = list: let
    # `binaryMerge start end` merges the elements at indices `index` of `list` such that `start <= index < end`
    # Type: Int -> Int -> Attrs
    binaryMerge = start: end:
    # assert start < end; # Invariant
      if end - start >= 2
      then
        # If there's at least 2 elements, split the range in two, recurse on each part and merge the result
        # The invariant is satisfied because each half will have at least 1 element
        binaryMerge start (start + (end - start) / 2) // binaryMerge (start + (end - start) / 2) end
      else
        # Otherwise there will be exactly 1 element due to the invariant, in which case we just return it directly
        elemAt list start;
  in
    if list == []
    then
      # Calling binaryMerge as below would not satisfy its invariant
      {}
    else binaryMerge 0 (length list);
}
