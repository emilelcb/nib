{
  description = "MyNib - My Nix Library";

  inputs.systems.url = "github:nix-systems/default";

  outputs = {self, ...} @ inputs: let
    systems = import inputs.systems;
  in
    import ./nib {inherit systems;};
}
