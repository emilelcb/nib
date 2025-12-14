{nib, ...}: rec {
  # Terminal Monad
  # Wrapper around a value (preserves lazy eval for the value)
  Terminal = value: {
    _nbtype_ = "nib::Terminal";
    _value_ = value;
  };

  # Pattern Matching
  isTerminal = T:
    (builtins.attrNames T == ["_nbtype_" "_value_"])
    && T._nbtype_ == "nib::Terminal";

  # Unwrap (Monadic Return Operation)
  unwrapTerminal = T:
    assert isTerminal T || nib.panic.badType "Terminal" T;
      T._value_;

  # Map (Monadic Bind Operation)
  mapTerminal = f: T: Terminal (f (unwrapTerminal T));
}
