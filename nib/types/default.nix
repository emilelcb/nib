{nib, ...} @ args: let
  fault = import ./fault.nix args;
  maybe = import ./maybe.nix args;
  res = import ./res.nix args;
  terminal = import ./terminal.nix args;
in
  nib.std.mergeAttrsList [
    # submodule is included directly to this module (ie self.myFunc)
    fault
    maybe
    res
    terminal
  ]
