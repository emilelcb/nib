{nib, ...}: let
  Res = nib.types.Res;
  findFirst = nib.std.findFirst;
  # TODO: try get enum generation working (and other type constructors)
  # Maybe = mkEnum "nib::Maybe" {
  #   Some = mkEnumVariant {value = "nix::String";};
  #   None = mkEnumVariant {};
  # };
  # TODO: you could even simplify this and pregenerate
  # TODO: monadic operations by defining:
  # mkMonad = mkEnum ... (blah blah blah)
  #
  # NOTE: internal view:
  # NOTE: sum == enum
  # NOTE: product == struct
  # NOTE: terminal == literal/epsilon (in EBNF/Extended Backus-Naur form)
  # Maybe = {
  #   # "adt" aka "algebraic data type"
  #   _adt_ = nib.types.adt.sum;
  #   _type_ = "Maybe"; # full type signature is "nib::Maybe"
  #   _vars_ = [
  #     {
  #       _adt_ = nib.types.adt.product;
  #       _type_ = "Some"; # type signature is "nib::Maybe::Some"
  #       _body_ = [
  #         # the name "value" was chosen by the user, its not inherit to nib
  #         value = {
  #           _adt_ = nib.types.adt.terminal;
  #           # nib.typeSig simply parses the string by splitting on "::" and forming a list
  #           _sig_ = nib.typeSig "nix::String";
  #         };
  #       ];
  #     };
  #     {
  #       _adt_ = nib.types.adt.terminal;
  #       _type_ = "None"; # type signature is "nib::Maybe::None"
  #       _sig_ = nib.typeSig "nix::Null";
  #     };
  #   ];
  #   None = {
  #
  #   };
  #   _body_ = {
  #     _some_ = some; # allows _value_ to be null (yuck!!)
  #     _value_ = value;
  #   };
  # };
  #
  # TODO: you could enforceType types as follows
  # DEFINE: enforce = pred: var:
  # DEFINE:   assert (pred var) || throw "..."; var;
  # DEFINE: enforceType = type:
  # DEFINE:   enforce (var: nib.typeOf var == type)
  # value: let
  #   # NOTE: var is either a fixed-point of enforceType or fails
  #   # NOTE: either way you don't need to worry about a recursive definition!
  #   var = enforceType "nib::Maybe" var;
  # in { ... }
in rec {
  # Maybe (Option) Monad
  Maybe = some: value: {
    _some_ = some; # allows _value_ to be null (yuck!!)
    _value_ = value;
  };
  Some = value: Res true value;
  None = Maybe false null;

  # Pattern Matching
  isMaybe = T: builtins.attrNames T == ["_some_" "_value_"];
  isSome = T: isMaybe T && T._some_;
  isNone = T: isMaybe T && !T._some_;

  # Unwrap (Monadic Return Operation)
  unwrapMaybe = f: g: T:
    if isSome T
    then f T._value_
    else g T._value_;

  # Map (Monadic Bind Operation)
  mapMaybe = f: T:
    if isSome T
    then Some (f T._value_)
    else None;
  # NOTE: yes this does nothing, its only here so I don't forget
  # NOTE: (ie when pregenerating monadic operations with a custom ADT module)
  mapSome = f: mapMaybe f;

  # Conditionals
  someOr = f: T:
    if isSome T
    then T
    else f T;

  noneOr = f: T:
    if isNone T
    then T
    else f T;

  firstSome = findFirst isSome None;

  nullableToMaybe = x:
    if x == null
    then None
    else Some x;
}
