{...}: let
  inherit
    (builtins)
    warn
    ;
in {
  id = x: x;

  min = x: y:
    if x < y
    then x
    else y;

  max = x: y:
    if x > y
    then x
    else y;

  warnIf = cond: msg:
    if cond
    then warn msg
    else x: x;
}
