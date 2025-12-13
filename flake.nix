{
  description = "MyNib - My Nix Library";

  inputs.systems.url = "github:nix-systems/default";

  outputs = {
    self,
    systems,
    ...
  }:
    import ./nib {inherit systems;};
}
