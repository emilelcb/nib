{lists, ...}: rec {
  # Result Monad
  Ok = value: {
    success = true;
    value = value;
  };
  Err = err: {
    success = false;
    value = err;
  };

  # Pattern Matching
  isResult = r: builtins.attrNames r == ["success" "value"];
  isOk = r: isResult r && r.success;
  isErr = r: isResult r && !r.success;

  # Unwrap (Monadic Return Operation)
  unwrap = f: r:
    if isOk r
    then r.value
    else f r.value;

  unwrapDefault = default: unwrap (_: default);

  # Map (Monadic Bind Operation)
  identity = r: r;

  map = r: f: g:
    if isOk r
    then Ok (f r.value)
    else Err (g r.value);
  mapOk = f: map f identity;
  mapErr = f: map identity f;

  # Conditionals
  okOr = r: f:
    if isOk r
    then r
    else f r;

  errOr = r: f:
    if isErr r
    then r
    else f r;

  firstErr = lists.findFirst isErr (Ok "No errors");
}
