{...} @ args: let
  attrs = import ./attrs.nix args;
  lists = import ./lists.nix args;
  trivial = import ./trivial.nix args;
in
  attrs.mergeAttrsList [
    # submodule is included directly to this module (ie self.myFunc)
    attrs
    lists
    trivial
  ]
