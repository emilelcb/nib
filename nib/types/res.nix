{nib, ...}: let
  findFirst = nib.std.findFirst;
in rec {
  # Res (Result) Monad
  Res = success: value: {
    _success_ = success;
    _value_ = value;
  };
  Ok = value: Res true value;
  Ok' = Ok "ok";
  Err = value: Res false value;
  Err' = Err "err";

  # Pattern Matching
  isRes = R: builtins.attrNames R == ["_success_" "_value_"];
  isOk = R: isRes R && R._success_;
  isErr = R: isRes R && !R._success_;

  # Unwrap (Monadic Return Operation)
  unwrapRes = f: g: R:
    if isOk R
    then f R._value_
    else g R._value_;
  unwrapOk = f: unwrapRes (R: R._value_) f;
  unwrapErr = f: unwrapRes f (R: R._value_);

  # Map (Monadic Bind Operation)
  mapRes = f: g: unwrapRes (R: Ok (f R)) (R: Err (f R));
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

  # Standard Helpers
  firstErr = findFirst isErr Ok';
}
