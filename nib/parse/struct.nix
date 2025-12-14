{
  attrs,
  result,
  ...
}: rec {
  cmpStructErr' = errBadKeys: errBadValues: path: S: T:
    if builtins.isAttrs S && builtins.isAttrSet T
    then let
      keysS = builtins.attrNames S;
      keysT = builtins.attrNames T;
    in
      # ensure all key names match, then recurse
      if !(keysS == keysT)
      then errBadKeys path keysS keysT
      else
        (result.firstErr
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
    (path: keysS: keysT:
      result.Err {
        reason = "keys";
        inherit path;
      })
    (path: S: T:
      result.Ok "ok");

  cmpTypedStruct =
    cmpStructErr
    (path: keysS: keysT:
      result.Err {
        reason = "keys";
        inherit path;
      })
    (path: S: T:
      result.Err {
        reason = "values";
        inherit path;
      });

  # check is a function taking two structs
  # and returning a result monad.
  mergeStruct' = check: template: S: let
    res = check template S;
  in
    result.errOr res ({...}:
      attrs.mapAttrsRecursive (
        path: value: let
          valueS = attrs.attrValueAt S path;
        in
          if valueS != null
          then valueS
          else value
      )
      template);

  mergeStruct = mergeStruct' (S: T: result.Ok "ok");

  mergeTypedStruct = mergeStruct' (
    cmpStructErr
    (path: keysS: keysT:
      result.Ok "ok")
    (path: S: T:
      result.Err {
        reason = "values";
        inherit path;
      })
  );

  mergeStructStrict = mergeStruct' cmpStruct;

  mergeTypedStructStrict = mergeStruct' cmpTypedStruct;
}
