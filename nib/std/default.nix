{...} @ args: let
  attrs = import ./attrs.nix args;
  functions = import ./functions.nix args;
  lists = import ./lists.nix args;
  trivial = import ./trivial.nix args;
in
  attrs.mergeAttrsList [
    attrs
    functions
    lists
    trivial
  ]
