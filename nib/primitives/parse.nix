{this, ...}: let
  inherit
    (builtins)
    foldl'
    hasAttr
    isAttrs
    ;

  inherit
    (this)
    enfType
    is
    Wrap
    ;
in rec {
  # form: getAttrAt :: list string -> set -> null | Wrap Any
  # given path as a list of strings, return that value of an
  # attribute set at that path
  getAttrAt = path: xs:
    assert enfType "set" xs "getAttrAt";
      foldl' (left: right:
        if left != null && isAttrs left.value && hasAttr right left.value
        then Wrap left.value.${right}
        else null)
      (Wrap xs)
      path;

  # form: hasAttrAt :: list string -> set -> bool
  # given path as a list of strings, return that value of an
  # attribute set at that path
  hasAttrAt = path: xs:
    assert enfType "set" xs "hasAttrAt";
      getAttrAt path xs != null; # NOTE: inefficient (im lazy)

  # Alternative to mapAttrsRecursiveCond
  # Allows mapping directly from a child path
  recmap = let
    recmapFrom = path: f: T:
      if builtins.isAttrs T && ! is Wrap T
      then builtins.mapAttrs (attr: leaf: recmapFrom (path ++ [attr]) f leaf) T
      else f path T;
  in
    recmapFrom [];

  projectOnto = f: dst: src:
    dst
    |> recmap
    (path: dstLeaf: let
      srcLeaf = getAttrAt path src;
      newLeaf =
        if srcLeaf != null
        then srcLeaf
        else dstLeaf;
    in
      if is Wrap newLeaf
      then newLeaf.value
      else newLeaf);
}
