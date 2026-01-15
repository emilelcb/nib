{nib, ...}: let
  inherit
    (builtins)
    isPath
    substring
    stringLength
    ;

  inherit
    (nib.trivial)
    warnIf
    ;
in rec {
  # re-export builtin string methods
  inherit
    substring
    stringLength
    ;

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
}
