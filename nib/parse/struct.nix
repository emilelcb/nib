{nib, ...}:
with nib.types; let
  attrs = nib.attrs;
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
          (builtins.map
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

  # check is a function taking two structs
  # and returning a result monad.
  mergeStruct' = check: template: S: let
    R = check template S;
  in
    errOr ({...}:
      Ok (
        attrs.mapAttrsRecursive (
          path: value: let
            valueS = attrs.attrValueAt S path;
          in
            if valueS != null
            then valueS
            else value
        )
        template
      ))
    R;

  # mergeStruct ensures no properties are evaluated (entirely lazy)
  mergeStruct = mergeStruct' (_: _: Ok');

  # mergeTypedPartialStruct must evaluate properties (not lazy)
  # for lazy evaluation use mergeStruct instead!
  mergeTypedPartialStruct = mergeStruct' cmpTypedPartialStruct;
}
