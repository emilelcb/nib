{systems, ...}: let
  std = import ./std;
in
  std
  // {
    # === External Functions ===
    withPkgs = repo: config: system:
      import repo {
        inherit system;
      }
      // config;

    mkSys = input: {
      forAllSystems = f:
        std.genAttrs systems (
          system: f system input.pkgs
        );
    };

    mkUSys = input: {
      forAllSystems = f:
        std.genAttrs systems (
          system: f system input.pkgs input.upkgs
        );
    };
  }
