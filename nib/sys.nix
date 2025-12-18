{
  systems,
  nib,
  ...
}: let
  std = nib.std;
in {
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
