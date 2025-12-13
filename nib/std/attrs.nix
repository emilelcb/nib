{lists}: rec {
  nameValuePair = name: value: {inherit name value;};

  listToAttrsIdentity = values:
    builtins.listToAttrs (
      builtins.map
      (x: nameValuePair x x)
      values
    );

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
  genAttrs' = xs: f: builtins.listToAttrs (map f xs);

  mapAttrsRecursiveCond = cond: f: set: let
    recurse = path:
      builtins.mapAttrs (
        name: value:
          if builtins.isAttrs value && cond value
          then recurse (path ++ [name]) value
          else f (path ++ [name]) value
      );
  in
    recurse [] set;

  mapAttrsRecursive = f: set: mapAttrsRecursiveCond (as: true) f set;

  # form: attrValueAt :: xs -> path -> value
  # given path as a list of strings, return that value of an
  # attribute set at that path
  attrValueAt = lists.foldl (l: r:
    if l != null && builtins.hasAttr r l
    then l.${r}
    else null);
}
