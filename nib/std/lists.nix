rec {
  foldl = op: nul: list: let
    foldl' = n:
      if n == -1
      then nul
      else op (foldl' (n - 1)) (builtins.elemAt list n);
  in
    foldl' (builtins.length list - 1);

  crossLists = f: foldl (fs: args: builtins.concatMap (f: map f args) fs) [f];
}
