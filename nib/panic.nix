{nib, ...}: {
  badType = expect: x:
    throw "Expected type ${expect} but got ${nib.typeOf x}.";
}
