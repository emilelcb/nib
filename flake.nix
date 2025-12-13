{
  description = "MyNib - My Nix Library";

  inputs.systems = "github:nix-systems/default";

  outputs = {
    self,
    systems,
    ...
  } @ inputs:
    import ./nib {inherit systems;};
}
