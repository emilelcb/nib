{...}: {
  badType = expect: x:
    throw "Expected type ${expect} but got ${builtins.typeOf x}.";
}
