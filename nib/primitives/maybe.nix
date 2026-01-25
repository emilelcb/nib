{this, ...}: let
  inherit
    (this)
    ntTrapdoorKey
    ntDynamicTrapdoorKey
    mkTrapdoorFn
    mkTrapdoorSet
    ;
in {
  # NOTE: Maybe is used to simplify parsing Type/Class declarations
  # NOTE: and therefore must be implemented manually
  Maybe = let
    meta = instance: {
      sig = "nt::&Maybe";
      derive = [];
      ops = {};
      req = {"nt::&Maybe" = ["unwrap"];};
    };
  in
    mkTrapdoorFn {
      default = {
        unwrap = "TODO";
      };
      unlock.${ntTrapdoorKey} = meta false;
    };

  Some = let
    meta = instance: {
      inherit instance;
      sig = "nt::Some";
      derive = ["nt::&Maybe"];
      ops = {
        "nt::&Maybe".unwrap = f: self: f self.${ntDynamicTrapdoorKey}.value;
      };
      req = {};
    };
  in
    mkTrapdoorFn {
      default = value:
        mkTrapdoorSet {
          unlock = {
            ${ntTrapdoorKey} = meta true;
            ${ntDynamicTrapdoorKey} = {
              inherit value;
            };
          };
        };
      unlock.${ntTrapdoorKey} = meta false;
    };

  None = let
    meta = instance: {
      inherit instance;
      sig = "nt::None";
      derive = ["nt::&Maybe"];
      ops = {
        "nt::&Maybe".map = f: self: self;
      };
      req = {};
    };
  in
    mkTrapdoorFn {
      default = mkTrapdoorSet ntTrapdoorKey {
        unlock = meta true;
      };
      unlock.${ntTrapdoorKey} = meta false;
    };
}
