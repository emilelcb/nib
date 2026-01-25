{this, ...}: let
  inherit
    (builtins)
    isString
    split
    stringLength
    ;

  inherit
    (this)
    enfIsNT
    ntTrapdoorKey
    ;

  inherit
    (this.util)
    filterEven
    init
    last
    nullOr
    stringHead
    stringTail
    ;
in rec {
  parseSig = sig: let
    result = split "::" sig |> filterEven;
  in
    if last result == ""
    then null
    else result;

  isTypeName = name: stringHead name != "&";
  isClassName = name: stringHead name == "&" && stringLength name != 1;

  isTypeSig = sig:
    parseSig sig |> nullOr (result: last result |> isTypeName);

  isClassSig = sig:
    parseSig sig |> nullOr (result: last result |> isClassSig);

  parseTypeSig = sig: let
    result = parseSig sig;
  in
    if result != null && (last result |> isTypeName)
    then result
    else null;

  parseClassSig = sig: let
    result = parseSig sig;
  in
    if result != null && (last result |> isClassName)
    then init result ++ (last result |> stringTail)
    else null;

  # NOTE: unsafe variant, use typeSig if you can't guarantee `isNT T` holds
  typeSig' = T: T.${ntTrapdoorKey}.sig;

  # NOTE: safe variant, use typeSig' if you can guarantee `isNT T` holds
  typeSig = T: assert enfIsNT "nt.typeSig" T; typeSig' T;

  toTypeSig = x:
    if isString x
    then x
    else typeSig x;

  # NOTE: we're testing how similar `list` is to `toTypeSig type` (non-commutative)
  # NOTE: we measure similarity in the reverse order (ie end of signature is most important)
  # sigSimilarity = type: list: let
  #   # XXX: TODO: mkClass must enforce that type names can't begin with &
  #   trimClassPrefix = sig:
  #     if stringHead sig == "&"
  #     then stringTail sig
  #     else sig;
  #   S = toTypeSig type |> parseTypeSig |> map trimClassPrefix;

  #   progress = l: x: let
  #     index = firstIndexOf x l;
  #   in
  #     if index == null
  #     then []
  #     else sublist index (length l - index) l;

  #   op = state: el: let
  #     acc' = progress state.acc el;
  #   in
  #     # Continue progression in healthy condition
  #     if state.acc != [] && acc' != []
  #     then {
  #       score = state.score + 1;
  #       acc = acc';
  #     }
  #     # We didn't match the final element (ABORT with score=0)
  #     else if state.score == 0
  #     then {
  #       score = 0;
  #       acc = [];
  #     }
  #     # We didn't match this element but maybe next time :)
  #     else state;
  # in
  #   list
  #   |> foldr op {
  #     score = 0;
  #     acc = reverse S;
  #   }
  #   |> getAttr "score";
}
