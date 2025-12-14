{systems, ...}: let
  # TODO: move this to a new module
  mkMod' = args: mod: import mod args;
  mkMod = mkMod' {inherit nib;};

  std = mkMod ./std;
  types = mkMod ./types;
  parse = mkMod ./parse;

  nib = std.mergeAttrsList [
    # submodule content is accessible first by submodule name
    # then by the name of the content (ie self.submodule.myFunc)
    {inherit std types parse;}

    # submodule is included directly to this module (ie self.myFunc)

    # this module
    {
      # === External Functions ===
      withPkgs = repo: config: system:
        import repo {
          inherit system;
        }
        // config;

      mkSys = input: let
        # function taking a system as argument
        pkgsFor = input.pkgs;
      in {
        inherit pkgsFor;
        forAllSystems = f:
          std.genAttrs systems (
            system: f system (pkgsFor system)
          );
      };

      mkUSys = input: let
        # functions taking a system as argument
        pkgsFor = input.pkgs;
        upkgsFor = input.upkgs;
      in {
        inherit pkgsFor upkgsFor;
        forAllSystems = f:
          std.genAttrs systems (
            system: f system (pkgsFor system) (upkgsFor system)
          );
      };
    }
  ];
in
  nib
