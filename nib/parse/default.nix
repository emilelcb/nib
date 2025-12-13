{
  attrs,
  result,
}: let
  struct = import ./struct.nix {inherit attrs result;};
in
  attrs.mergeAttrsList [
    # submodule is included directly to this module (ie self.myFunc)
    struct

    # submodule content is accessible first by submodule name
    # then by the name of the content (ie self.submodule.myFunc)
  ]
