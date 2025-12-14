{...}:
with builtins; rec {
  # Fault Monad
  # Wrapper around an error (ie builtins.abort)
  Fault = error: {
    _error_ = error;
  };

  # Pattern Matching
  isFault = F: attrNames F == ["_error_"];

  # Unwrap (Monadic Return Operation)
  unwrapFault = F: F._error_;

  # Map (Monadic Bind Operation)
  mapFault = f: F: Fault (f (unwrapFault F));
}
