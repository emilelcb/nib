{nib, ...} @ args: let
  fault = import ./fault.nix args;
  group = import ./group.nix args;
  maybe = import ./maybe.nix args;
  res = import ./res.nix args;
  terminal = import ./terminal.nix args;
in
  nib.std.mergeAttrsList [
    # submodule is included directly to this module (ie self.myFunc)
    fault
    group
    maybe
    res
    terminal

    rec {
      # TODO
      isAlgebraic = T: false;

      isList = T: !isAlgebraic T && builtins.isList T;
      isAttrs = T: !isAlgebraic T && builtins.isAttrs T;
    }
  ]
