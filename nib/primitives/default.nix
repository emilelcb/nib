{mix, ...} @ inputs:
mix.newMixture inputs (mixture: {
  includes.public = [
    ./rose.nix
    ./std.nix
  ];
})
