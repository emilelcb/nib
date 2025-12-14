{...}: rec {
  # Fault Monad
  # Wrapper around an error (ie builtins.abort)
  Fault = error: {
    error = error;
  };

  # Pattern Matching
  isFault = F: builtins.attrNames F == ["error"];

  # Unwrap (Monadic Return Operation)
  unwrapFault = F: F.error;

  # Map (Monadic Bind Operation)
  mapFault = f: F: Fault (f (unwrapFault F));
}
