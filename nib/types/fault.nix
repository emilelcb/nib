{nib, ...}: rec {
  # Fault Monad
  # Wrapper around an error (ie builtins.abort)
  Fault = error: {
    _error_ = error;
  };

  # Pattern Matching
  isFault = T: builtins.attrNames T == ["_error_"];

  # Unwrap (Monadic Return Operation)
  unwrapFault = T:
    assert isFault T || nib.panic.badType "Fault" T;
      T._error_;

  # Map (Monadic Bind Operation)
  mapFault = f: T: Fault (f (unwrapFault T));
}
