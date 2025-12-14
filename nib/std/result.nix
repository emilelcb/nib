{lists, ...}: rec {
  # Result Monad
  Ok = value: {
    ok = true;
    value = value;
  };
  Err = err: {
    ok = false;
    error = err;
  };

  # Pattern Matching
  isResult = r:
    (builtins.length (builtins.attrNames r) == 2)
    && builtins.hasAttr "ok" r
    && (builtins.hasAttr "value" r || builtins.hasAttr "error" r);
  isOk = r: isResult r && r.ok;
  isErr = r: isResult r && !r.ok;

  # Unwrap (Monadic Return Operation)
  unwrap = f: r:
    if isOk r
    then r.value
    else f r.error;

  unwrapDefault = default: unwrap (x: default);

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
