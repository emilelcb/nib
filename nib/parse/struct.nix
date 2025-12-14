{nib, ...}:
with builtins;
with nib.types; rec {
  cmpStructErr' = errBadKeys: errBadValues: path: S: T:
    if isAttrs S && isAttrs T
    then let
      keysS = attrNames S;
      keysT = attrNames T;
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
      (typeOf S == typeOf T)
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

  mergeStructs' = f: cond: S: T:
    mapAttrsRecursiveCond
    cond
    (path: valueS: let
      valueT = attrValueAt T path;
    in
      unwrapSome valueT (_: f valueS))
    S;

  # mergeStruct ensures no properties are evaluated (entirely lazy)
  mergeStructs = mergeStruct (x: x);

  # given a template struct, and the struct to parse
  parseStructFor =
    mergeStructs'
    (leaf: !isTerminal leaf)
    (value:
      if isTerminal value
      then unwrapTerminal value
      else valueS);

  # TODO: Define:
  # TODO: throwUnreachable = throw "Unreachable code was evaluated..";
  # TODO: abortUnreachable = abort "Unreachable code was evaluated...";
  mergeStruct = mergeStruct' (_: _: Ok');

  # mergeTypedPartialStruct must evaluate properties (not lazy)
  # for lazy evaluation use mergeStruct instead!
  mergeTypedPartialStruct = mergeStruct' cmpTypedPartialStruct;
}
