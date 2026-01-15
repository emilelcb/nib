{nib, ...}: let
  inherit
    (builtins)
    all
    attrNames
    elemAt
    filter
    getAttr
    hasAttr
    isAttrs
    length
    listToAttrs
    mapAttrs
    ;

  inherit
    (nib.std)
    foldl
    ;

  inherit
    (nib.types)
    nullableToMaybe
    ;
in rec {
  nameValuePair = name: value: {inherit name value;};

  identityAttrs = value: {${value} = value;};

  identityAttrsMany = values: map (v: identityAttrs v) values;

  hasAttrs = list: xs: all (x: hasAttr x xs) list;

  getAttrOr = name: xs: default:
    if hasAttr name xs
    then getAttr name xs
    else default;

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

  # form: attrValueAt :: list string -> set -> Maybe Any
  # given path as a list of strings, return that value of an
  # attribute set at that path
  attrValueAt = path: xs:
    foldl (left: right:
      if isAttrs left && hasAttr right left
      then left.${right}
      else null)
    xs
    path
    |> nullableToMaybe;

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

  /**
  Filter an attribute set by removing all attributes for which the
  given predicate return false.

  # Inputs

  `pred`

  : Predicate taking an attribute name and an attribute value, which returns `true` to include the attribute, or `false` to exclude the attribute.

    <!-- TIP -->
    If possible, decide on `name` first and on `value` only if necessary.
    This avoids evaluating the value if the name is already enough, making it possible, potentially, to have the argument reference the return value.
    (Depending on context, that could still be considered a self reference by users; a common pattern in Nix.)

    <!-- TIP -->
    `filterAttrs` is occasionally the cause of infinite recursion in configuration systems that allow self-references.
    To support the widest range of user-provided logic, perform the `filterAttrs` call as late as possible.
    Typically that's right before using it in a derivation, as opposed to an implicit conversion whose result is accessible to the user's expressions.

  `set`

  : The attribute set to filter

  # Type

  ```
  filterAttrs :: (String -> Any -> Bool) -> AttrSet -> AttrSet
  ```

  # Examples
  :::{.example}
  ## `lib.attrsets.filterAttrs` usage example

  ```nix
  filterAttrs (n: v: n == "foo") { foo = 1; bar = 2; }
  => { foo = 1; }
  ```

  :::
  */
  filterAttrs = pred: set: removeAttrs set (filter (name: !pred name set.${name}) (attrNames set));
}
