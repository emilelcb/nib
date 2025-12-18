{...}: {
  id = x: x;

  min = x: y:
    if x < y
    then x
    else y;

  max = x: y:
    if x > y
    then x
    else y;
}
