{...}: rec {
  isType = type: T: type == typeOf T;
  isSameType = T1: T2: typeOf T1 == typeOf T2;

  # TODO
  typeOf = builtins.typeOf;
  # TODO
  typeName = typeOf;
}
