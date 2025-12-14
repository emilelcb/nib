{nib, ...}: rec {
  # Res (Result) Monad
  Res = success: value: {inherit success value;};
  Ok = value: Res true value;
  Ok' = Ok "ok";
  Err = value: Res false value;
  Err' = Err "err";

  # Pattern Matching
  isRes = R: builtins.attrNames R == ["success" "value"];
  isOk = R: isRes R && R.success;
  isErr = R: isRes R && !R.success;

  # Unwrap (Monadic Return Operation)
  unwrapRes = f: R:
    if isErr R
    then f R.value
    else R.value;

  # Map (Monadic Bind Operation)
  mapRes = f: g: R:
    if isOk R
    then Ok (f R.value)
    else Err (g R.value);
  mapOk = f: mapRes f (x: x);
  mapErr = f: mapRes (x: x) f;

  # Conditionals
  okOr = f: R:
    if isOk R
    then R
    else f R;

  errOr = f: R:
    if isErr R
    then R
    else f R;

  firstErr = nib.types.findFirst isErr Ok';
}
