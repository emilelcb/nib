{nib, ...}: rec {
  enfType = type: T:
    assert (nib.isType type T
      || nib.panic.badType (nib.typeName type) T); true;

  enfSameType = T1: T2: enfType (nib.typeOf T1) T2;

  enfAttrs = enfType (nib.typeOf {});
  enfList = enfType (nib.typeOf []);
  enfListOf = type: L:
    assert (enfList L
      && builtins.all (T: nib.isType type T) L
      || nib.panic.badType "List ${nib.typeName type}" L); true;
}
