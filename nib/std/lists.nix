{nib, ...}: let
  inherit
    (nib.std)
    min
    ;
in rec {
  foldl = op: nul: list: let
    foldl' = n:
      if n == -1
      then nul
      else op (foldl' (n - 1)) (builtins.elemAt list n);
  in
    foldl' (builtins.length list - 1);

  crossLists = f: foldl (fs: args: builtins.concatMap (f: map f args) fs) [f];

  findFirstIndex = pred: default: list: let
    # A naive recursive implementation would be much simpler, but
    # would also overflow the evaluator stack. We use `foldl'` as a workaround
    # because it reuses the same stack space, evaluating the function for one
    # element after another. We can't return early, so this means that we
    # sacrifice early cutoff, but that appears to be an acceptable cost. A
    # clever scheme with "exponential search" is possible, but appears over-
    # engineered for now. See https://github.com/NixOS/nixpkgs/pull/235267
    # Invariant:
    # - if index < 0 then el == elemAt list (- index - 1) and all elements before el didn't satisfy pred
    # - if index >= 0 then pred (elemAt list index) and all elements before (elemAt list index) didn't satisfy pred
    #
    # We start with index -1 and the 0'th element of the list, which satisfies the invariant
    resultIndex =
      builtins.foldl' (
        index: el:
          if index < 0
          then
            # No match yet before the current index, we need to check the element
            if pred el
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
    then default
    else resultIndex;

  findFirst = pred: default: list: let
    index = findFirstIndex pred null list;
  in
    if index == null
    then default
    else builtins.elemAt list index;

  zipListsWith = f: fst: snd:
    builtins.genList (n: f (builtins.elemAt fst n) (builtins.elemAt snd n)) (min (builtins.length fst) (builtins.length snd));

  # zipLists = zipListsWith (fst: snd: {inherit fst snd;});
}
