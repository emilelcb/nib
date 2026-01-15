{nib, ...}: let
  inherit
    (builtins)
    isPath
    genList
    replaceStrings
    substring
    stringLength
    ;

  inherit
    (nib.std)
    warnIf
    ;
in rec {
  # re-export builtin string methods
  inherit
    replaceStrings
    substring
    stringLength
    ;

  escape = list: replaceStrings list (map (c: "\\${c}") list);

  escapeRegex = escape (stringToCharacters "\\[{()^$?*+|.");

  hasInfix = infix: content:
  # Before 23.05, paths would be copied to the store before converting them
  # to strings and comparing. This was surprising and confusing.
    warnIf (isPath infix)
    ''
      lib.strings.hasInfix: The first argument (${toString infix}) is a path value, but only strings are supported.
          There is almost certainly a bug in the calling code, since this function always returns `false` in such a case.
          This function also copies the path to the Nix store, which may not be what you want.
          This behavior is deprecated and will throw an error in the future.''
    (builtins.match ".*${escapeRegex infix}.*" "${content}" != null);

  removeSuffix = suffix: str:
  # Before 23.05, paths would be copied to the store before converting them
  # to strings and comparing. This was surprising and confusing.
    warnIf (isPath suffix)
    ''
      lib.strings.removeSuffix: The first argument (${toString suffix}) is a path value, but only strings are supported.
          There is almost certainly a bug in the calling code, since this function never removes any suffix in such a case.
          This function also copies the path to the Nix store, which may not be what you want.
          This behavior is deprecated and will throw an error in the future.''
    (
      let
        sufLen = stringLength suffix;
        sLen = stringLength str;
      in
        if sufLen <= sLen && suffix == substring (sLen - sufLen) sufLen str
        then substring 0 (sLen - sufLen) str
        else str
    );

  stringToCharacters = s: genList (p: substring p 1 s) (stringLength s);
}
