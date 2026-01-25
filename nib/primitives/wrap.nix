{this, ...}: let
  inherit
    (this)
    ntTrapdoorKey
    mkTrapdoorFn
    mkTrapdoorSet
    ;
in {
  # NOTE: Wrap is used to simplify parsing Type/Class declarations
  # NOTE: and therefore must be implemented manually
  Wrap = let
    meta = instance: {
      inherit instance;
      sig = "nt::Wrap";
      derive = [];
      ops = {};
      req = {};
    };
  in
    mkTrapdoorFn ntTrapdoorKey {
      default = value:
        mkTrapdoorSet ntTrapdoorKey {
          default = {inherit value;};
          unlock = meta true;
        };
      unlock = meta false;
    };
}
