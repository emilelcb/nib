# XXX: TODO: allow trapdoors to have multiple keys, have a specific meta door that lists all available keys
# XXX: TODO: allow trapdoors to have multiple keys, have a specific meta door that lists all available keys
# XXX: TODO: allow trapdoors to have multiple keys, have a specific meta door that lists all available keys
# XXX: TODO: allow trapdoors to have multiple keys, have a specific meta door that lists all available keys
# XXX: TODO: allow trapdoors to have multiple keys, have a specific meta door that lists all available keys
# XXX: TODO: allow trapdoors to have multiple keys, have a specific meta door that lists all available keys
# XXX: TODO: allow trapdoors to have multiple keys, have a specific meta door that lists all available keys
# XXX: TODO: allow trapdoors to have multiple keys, have a specific meta door that lists all available keys
# XXX: TODO: allow trapdoors to have multiple keys, have a specific meta door that lists all available keys
# XXX: TODO: allow trapdoors to have multiple keys, have a specific meta door that lists all available keys
# XXX: TODO: allow trapdoors to have multiple keys, have a specific meta door that lists all available keys
# XXX: TODO: allow trapdoors to have multiple keys, have a specific meta door that lists all available keys
# XXX: TODO: allow trapdoors to have multiple keys, have a specific meta door that lists all available keys
# XXX: TODO: allow trapdoors to have multiple keys, have a specific meta door that lists all available keys
{this, ...}: let
  inherit
    (builtins)
    isFunction
    ;

  inherit
    (this)
    enfHasAttr
    enfHasAttr'
    enfIsType
    ;

  # holy moly its the matrix batman!!
  trapdoorCeption = "_''_''";
in rec {
  defaultTrapdoorKey = "_'";
  mkTrapdoorKey = id: "${defaultTrapdoorKey}${id}";
  ntTrapdoorKey = mkTrapdoorKey "nt";

  mkTrapdoorFn = key: decl:
    assert enfHasAttr "default" decl "mkTrapdoorFn";
    assert enfHasAttr' "unlock" decl "mkTrapdoorFn";
    # return trapdoor function
      (x:
        if x == key
        then decl.unlock
        else decl.default);

  mkTrapdoorSet = key: decl:
    assert enfHasAttr "default" decl "mkTrapdoorSet";
    assert enfHasAttr' "unlock" decl "mkTrapdoorSet";
    # return trapdoor set
      decl.default // {${key} = decl.unlock;};

  # openTrapdoorFn = key: f:
  #   assert enfHasAttr "openTrapdoor" key xs let
  #     content = xs ;
  #   in;
  #     xs.${key};

  openTrapdoorFn = key: f: let
    content = f key;
  in
    content;

  openTrapdoorSet = key: xs: let
    content = xs.${key};
  in
    content;

  openTrapdoor = key: T:
    if isFunction T
    then openTrapdoorFn key T
    else
      assert enfIsType "set" T "openTrapdoor";
        openTrapdoorSet key T;
}
