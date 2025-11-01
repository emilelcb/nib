{
  description = "MyNib - My Nix Library";

  inputs = {
    # # Externally extensible flake systems
    # # REF: https://github.com/nix-systems/nix-systems
    systems = {
      url = "github:nix-systems/default";
      flake = false;
    };
  };

  outputs = {
    self,
    inputs,
    ...
  } @ args: rec {
    # REF: https://github.com/nix-systems/nix-systems
    archs = {
      x86_64 = "x86_64";
      aarch64 = "aarch64";
      riscv64 = "riscv64";
    };

    osnames = {
      linux = "linux";
      darwin = "darwin";
    };

    systemName = arch: osname: "${arch}-${osname}";

    systems = let
      mkSystem = arch: osname: let x = systemName; in {x = x;};
    in
      with archs;
      with osnames; {
        inherit (mkSystem x86_64 linux);
        inherit (mkSystem x86_64 darwin);
        inherit (mkSystem aarh64 linux);
        inherit (mkSystem aarh64 darwin);
        inherit (mkSystem riscv64 linux);
      };
  };
}
