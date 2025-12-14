{systems, ...}: let
  mergeAttrsList = std.attrs.mergeAttrsList;

  std = import ./std {};
  stdSubMods = {
    attrs = std.attrs;
    fault = std.fault;
    lists = std.lists;
    result = std.result;
  };

  parse = import ./parse (mergeAttrsList [stdSubMods]);
in
  mergeAttrsList [
    # submodule content is accessible first by submodule name
    # then by the name of the content (ie self.submodule.myFunc)
    {inherit parse;}

    # submodule is included directly to this module (ie self.myFunc)
    std

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
          std.attrs.genAttrs systems (
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
          std.attrs.genAttrs systems (
            system: f system (pkgsFor system) (upkgsFor system)
          );
      };
    }
  ]
