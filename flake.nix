{
  description = "MyNib - My Nix Library";

  outputs = {
    self,
    systems,
    ...
  } @ inputs:
    import ./nib {};
}
