{}: let
  attrs = import ./attrs.nix {inherit lists;};
  lists = import ./lists.nix {};
  result = import ./lists.nix {inherit lists;};
in
  builtins.listToAttrs [
    # submodule is included directly to this module (ie self.myFunc)

    # submodule content is accessible first by submodule name
    # then by the name of the content (ie self.submodule.myFunc)
    {inherit attrs lists result;}
  ]
