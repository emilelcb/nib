{
  description = "MyNib - My Nix Library";

  inputs.systems.url = "github:nix-systems/default";

  outputs = {systems}:
    import ./nib {inherit systems;};
}
