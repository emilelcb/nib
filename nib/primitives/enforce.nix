{this, ...}: let
  inherit
    (builtins)
    hasAttr
    typeOf
    ;

  inherit
    (this)
    isClassSig
    isNT
    isTypeSig
    ;
in rec {
  enfType = msg: type: value: let
    got = typeOf value;
  in
    got == type || throw "${msg}: expected primitive nix type \"${type}\" but got \"${got}\"";

  # NOTE: doesn't check if xs is type set, use enfHasAttr instead
  enfHasAttr' = msg: name: xs:
    hasAttr name xs || throw "${msg}: missing required attribute \"${name}\"";

  # NOTE: use enfHasAttr' if you can guarantee xs is type set
  enfHasAttr = msg: name: xs:
    enfType "set" xs msg && enfHasAttr' name xs msg;

  enfIsClassSig = msg: sig:
    isClassSig sig || throw "${msg}: given value \"${toString sig}\" of primitive nix type \"${typeOf sig}\" is not a valid Typeclass signature";

  enfIsTypeSig = msg: sig:
    isTypeSig sig || throw "${msg}: given value \"${toString sig}\" of primitive nix type \"${typeOf sig}\" is not a valid Type signature";

  enfIsNT = msg: T:
    isNT T || throw "${msg}: expected nt compatible type but got \"${toString T}\" of primitive nix type \"${typeOf T}\"";
}
