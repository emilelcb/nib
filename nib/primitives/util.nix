# TODO: move these declarations to a separate module (maybe?)
{...}: let
  inherit
    (builtins)
    elem
    elemAt
    filter
    foldl'
    head
    genList
    length
    mapAttrs
    partition
    removeAttrs
    stringLength
    substring
    tail
    ;
in rec {
  id = x: x;
  flipCurry = f: a: b: f b a;

  inc = x: x + 1;
  dec = x: x - 1;

  sublist = start: count: list: let
    len = length list;
  in
    genList (n: elemAt list (n + start)) (
      if start >= len
      then 0
      else if start + count > len
      then len - start
      else count
    );

  take = count: sublist 0 count;

  init = list:
    assert (list != []) || throw "lists.init: list must not be empty!";
      take (length list - 1) list;

  last = list:
    assert (list != []) || throw "lists.last: list must not be empty!";
      elemAt list (length list - 1);

  # REF: pkgs.lib.lists.reverseList
  reverse = xs: let
    l = length xs;
  in
    genList (n: elemAt xs (l - n - 1)) l;

  # REF: pkgs.lib.lists.foldr
  foldr = op: nul: list: let
    len = length list;
    fold' = n:
      if n == len
      then nul
      else op (elemAt list n) (fold' (n + 1));
  in
    fold' 0;

  # REF: pkgs.lib.lists.findFirstIndex [MODIFIED]
  firstIndexOf = x: list: let
    resultIndex =
      foldl' (
        index: el:
          if index < 0
          then
            # No match yet before the current index, we need to check the element
            if el == x
            then
              # We have a match! Turn it into the actual index to prevent future iterations from modifying it
              -index - 1
            else
              # Still no match, update the index to the next element (we're counting down, so minus one)
              index - 1
          else
            # There's already a match, propagate the index without evaluating anything
            index
      ) (-1)
      list;
  in
    if resultIndex < 0
    then null
    else resultIndex;

  nullOr = f: x:
    if x != null
    then f x
    else x;

  stringElem = i: substring i 1;
  stringTake = substring 0;
  stringHead = stringTake 1;
  stringTail = x: x |> substring 1 (stringLength x - 1);
  stringInit = x: x |> stringTake 1;
  stringLast = x: stringElem (stringLength x - 1);

  countEvensLeq = n: n / 2;
  countOddsLeq = n: (n + 1) / 2;

  nats = genList id;

  odds = genList (x: 2 * x + 1);
  oddsLeq = n: countOddsLeq n |> genList (x: 2 * x + 1);

  evens = genList (x: 2 * x);
  evensLeq = n: countEvensLeq n |> genList (x: 2 * x);

  # WARNING: mapOdd/mapEven assuming the indexing set begins even (ie start counting from 0)
  mapOdd = f: list: oddsLeq (length list - 1) |> map (i: f (elemAt list i));
  mapEven = f: list: evensLeq (length list + 1) |> map (i: f (elemAt list i));

  # WARNING: filterOdd/filterEven assuming the indexing set begins even (ie start counting from 0)
  filterOdd = mapOdd id;
  filterEven = mapEven id;

  mergeAttrsList = list: let
    # `binaryMerge start end` merges the elements at indices `index` of `list` such that `start <= index < end`
    # Type: Int -> Int -> Attrs
    binaryMerge = start: end:
    # assert start < end; # Invariant
      if end - start >= 2
      then
        # If there's at least 2 elements, split the range in two, recurse on each part and merge the result
        # The invariant is satisfied because each half will have at least 1 element
        binaryMerge start (start + (end - start) / 2) // binaryMerge (start + (end - start) / 2) end
      else
        # Otherwise there will be exactly 1 element due to the invariant, in which case we just return it directly
        elemAt list start;
  in
    if list == []
    then
      # Calling binaryMerge as below would not satisfy its invariant
      {}
    else binaryMerge 0 (length list);

  removeAttrsRec = paths: xs: let
    parts = partition (p: length p == 1) paths;
    here = parts.right;
    next = parts.wrong;
  in
    xs
    |> flipCurry removeAttrs here
    |> mapAttrs (name:
      if ! elem name next
      then id
      else
        next
        |> filter (x: head x == name)
        |> map tail
        |> removeAttrsRec);
}
