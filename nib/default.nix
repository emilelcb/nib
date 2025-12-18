{systems, ...}: let
  # TODO: move this to a new module
  mkMod' = args: mod: import mod args;
  mkMod = mkMod' {inherit systems nib;};

  std = mkMod ./std;
  types = mkMod ./types;
  parse = mkMod ./parse;
  panic = mkMod ./panic.nix;
  sys = mkMod ./sys.nix;

  nib = std.mergeAttrsList [
    # submodule content is accessible first by submodule name
    # then by the name of the content (ie self.submodule.myFunc)
    {inherit std types panic parse;}

    # submodule content accessible directly (ie self.myFunc)
    sys
  ];
in
  nib
