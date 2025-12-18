{nib, ...}: let
  # Rust inspired pattern matching syntax:
  # resultA = match [platform arch] [
  #   (Pattern ["darwin" Any]                         darwin_package)
  #   (Pattern ["openbsd" "x86_64"]                   openbsd_x86_64_package)
  #   (Pattern [(x: x == "linux") (y: y == "x86_64")] linux_x86_64_package)
  #   (Pattern (x: y: x == "linux" && y == "aarch64") linux_aarch64_package)
  #   (Pattern Any                                    default_package)
  # ];
  # resultB = match [platform arch] [
  #   (["darwin" Any]                         |> case darwin_package)
  #   (["openbsd" "x86_64"]                   |> case openbsd_x86_64_package)
  #   ([(x: x == "linux") (y: y == "x86_64")] |> case linux_x86_64_package)
  #   ((x: y: x == "linux" && y == "aarch64") |> case linux_aarch64_package)
  #   (Any                                    |> case default_package)
  # ];
  types = nib.types;
in rec {
  Pattern = pattern: return: throw "not implemented";
  case = return: pattern: Pattern pattern return;

  matchesPattern' = pattern: subject: let
    recurse = p: s:
      nib.isSameType p s
      && (
        if nib.isList p
        then builtins.all (map (p: recurse p)) (nib.std.zipLists)
        else if nib.isAttrs p
        then builtins.all ()
        else nib.eq p s
      );
  in
    recurse pattern subject;

  # maybe' :: TList a b -> TList [TPattern c d] -> TMaybe d
  match' = subject: patterns:
    nib.enfType (types.TList types.TPattern) patterns
    && builtins.foldl' (
      fix: p:
        if types.isNone fix
        # maintain None as a fixed value
        then fix
        else matchesPattern' p
    )
    types.Some
    patterns;
}
