{...}: let
  attrs = import ./attrs.nix {inherit lists;};
  fault = import ./fault.nix {};
  lists = import ./lists.nix {};
  result = import ./result.nix {inherit lists;};
in
  attrs.mergeAttrsList [
    # submodule is included directly to this module (ie self.myFunc)
    attrs
    fault
    lists
    result

    # submodule content is accessible first by submodule name
    # then by the name of the content (ie self.submodule.myFunc)
  ]
