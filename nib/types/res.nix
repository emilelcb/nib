{nib, ...}: let
  findFirst = nib.std.findFirst;
in rec {
  # Res (Result) Monad
  Res = success: value: {
    _success_ = success;
    _value_ = value;
  };
  Ok = Res true;
  Ok' = Ok "ok";
  Err = Res false;
  Err' = Err "err";

  # Pattern Matching
  isRes = R: builtins.attrNames R == ["_success_" "_value_"];
  isOk' = R: isRes R && R._success_;
  isOk = R:
    assert isRes R || nib.panic.badType "Res" R;
      isOk' R;
  isErr' = R: isRes R && !R._success_;
  isErr = R:
    assert isRes R || nib.panic.badType "Res" R;
      isErr' R;

  # Unwrap (Monadic Return Operation)
  unwrapRes = f: g: R:
    if isOk R
    then f R._value_
    else g R._value_;
  unwrapOk = unwrapRes (v: v);
  unwrapErr = f: unwrapRes f (v: v);

  # Map (Monadic Bind Operation)
  mapRes = f: g: unwrapRes (v: Ok (f v)) (v: Err (f v));
  mapOk = f: mapRes f (v: v);
  mapErr = f: mapRes (v: v) f;

  # Conditionals
  okOr = f: R:
    if isOk R
    then R
    else f R;

  errOr = f: R:
    if isErr R
    then R
    else f R;

  # Standard Helpers
  firstErr = findFirst isErr' Ok';
}
