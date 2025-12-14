{nib, ...} @ args: let
  struct = import ./struct.nix args;
in
  nib.std.mergeAttrsList [
    # submodule is included directly to this module (ie self.myFunc)
    struct
  ]
