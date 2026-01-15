{nib, ...}: let
  inherit
    (nib.std)
    min
    ;
in {
  # yeah fuck the waiter!! it was cold anyways :(
  flipCurry = f: a: b: f b a;
}
