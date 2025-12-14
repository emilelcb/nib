{...}: rec {
  # Fault Monad
  # Wrapper around an error (ie builtins.abort)
  Fault = error: {
    error = error;
  };

  # Pattern Matching
  isFault = F: builtins.attrNames F == ["error"];

  # Unwrap (Monadic Return Operation)
  unwrap = F: F.error;

  # Map (Monadic Bind Operation)
  map = f: F: Fault (f (unwrap F));
}
