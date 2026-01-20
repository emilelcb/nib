{nib, ...}: let
  inherit
    (builtins)
    all
    attrNames
    attrValues
    hasAttr
    isAttrs
    ;
in rec {
  Group = meta: children:
    assert attrValues children |> all (g: isGroup g || nib.panic.badType "nib::Group" g);
      children
      // {
        # trapdoor attribute
        _' = {
          inherit meta;
          nbtype = "nib::Group";
        };
      };

  # Pattern Matching
  isGroup = G:
    isAttrs G
    && hasAttr "_'" G
    && attrNames G._' == ["nbtype" "meta"]
    && G._'.nbtype == "nib::Group";

  groupMeta = G:
    assert isGroup G || nib.panic.badType "nib::Group" G;
      G._'.meta;
}
