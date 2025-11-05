{
  description = "MyNib - My Nix Library";

  inputs = {
    # # Externally extensible flake systems
    # # REF: https://github.com/nix-systems/nix-systems
    systems.url = "github:nix-systems/default";
  };

  outputs = {
    self,
    inputs,
    ...
  } @ args: {
    inherit (import ./nib {});
  };
}
