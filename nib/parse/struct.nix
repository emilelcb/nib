{nib, ...}: let
  inherit
    (nib.types)
    Err
    Ok'
    firstErr
    unwrapSome
    isTerminal
    unwrapTerminal
    ;

  inherit
    (nib.std)
    attrValueAt
    ;
in rec {
  cmpStructErr' = errBadKeys: errBadValues: path: S: T:
    if builtins.isAttrs S && builtins.isAttrs T
    then let
      keysS = builtins.attrNames S;
      keysT = builtins.attrNames T;
    in
      # ensure all key names match, then recurse
      if !(keysS == keysT)
      then errBadKeys path keysS keysT
      else
        (firstErr
          (map
            (k: cmpStructErr' errBadKeys errBadValues (path ++ [k]) (keysS.${k}) (keysT.${k}))
            keysS))
    else
      # terminating leaf in recursion tree reached
      # ensure values' types match
      (builtins.typeOf S == builtins.typeOf T)
      || errBadValues path S T;

  cmpStructErr = errBadKeys: errBadValues: cmpStructErr' errBadKeys errBadValues [];

  cmpStruct =
    cmpStructErr
    (path: _: _:
      Err {
        reason = "keys";
        inherit path;
      })
    (_: _: _: Ok');

  cmpTypedStruct =
    cmpStructErr
    (path: _: _:
      Err {
        reason = "keys";
        inherit path;
      })
    (path: _: _:
      Err {
        reason = "values";
        inherit path;
      });

  cmpTypedPartialStruct =
    cmpStructErr
    (_: _: _: Ok')
    (path: _: _:
      Err {
        reason = "values";
        inherit path;
      });

  # Alternative to mapAttrsRecursiveCond
  # Allows mapping directly from a child path
  recmapCondFrom = path: cond: f: T: let
    delegate = path': recmapCondFrom path' cond f;
  in
    if builtins.isAttrs T && cond path T
    then builtins.mapAttrs (attr: leaf: delegate (path ++ [attr]) leaf) T
    # else if builtins.isList T
    # then map (leaf: delegate leaf)
    else f path T;

  recmapCond = recmapCondFrom [];

  # Alternative to mapAttrsRecursive
  # NOTE: refuses to go beyond Terminal types
  recmap = recmapCond (_: leaf: !(isTerminal leaf));

  overrideStructCond = cond: f: S: ext:
    recmapCond
    cond
    (path: leaf:
      attrValueAt path ext
      |> unwrapSome (_: f leaf))
    S;

  # overrideStruct ensures no properties are evaluated (entirely lazy)
  # TODO: should this be called "overlayStructs" or something? (its not exactly a override...)
  # NOTE: respects Terminal types
  overrideStructs =
    overrideStructCond
    (_: leaf: !(isTerminal leaf))
    (leaf:
      if isTerminal leaf
      then unwrapTerminal leaf
      else leaf);

  # # overrideTypedPartialStruct must evaluate properties (not lazy)
  # # for lazy evaluation use overrideStruct instead!
  # overrideTypedPartialStruct = overrideStructs' cmpTypedPartialStruct;

  overrideAttrs = A: B: A // B;
}
