{this, ...}: let
  inherit
    (builtins)
    all
    attrNames
    elem
    isAttrs
    isFunction
    length
    mapAttrs
    partition
    ;

  inherit
    (this)
    enfType
    enfIsClassSig
    enfIsNT
    hasAttrAt
    mkTrapdoorSet
    ntTrapdoorKey
    openTrapdoorFn
    parseClassSig
    projectOnto
    toTypeSig
    typeSig
    Wrap
    ;

  inherit
    (this.util)
    flipCurry
    removeAttrsRec
    ;

  recdef = def: let
    Self = def Self;
  in
    Self;

  classDecl = {
    derive = Wrap [];
    ops = Wrap {};
  };

  unwrapBuilder = builder: Self:
    if isFunction builder
    then builder Self
    else builder;

  parseDecl = base: decl:
    assert enfType "parseDecl" "set" decl;
    # ^^^^ "Type declaration must be provided as an attribute set, got "${typeOf decl}" instead!"
      decl |> projectOnto base;

  # Algorithm: given a full set of ops, iterate each op and
  # IF IT MATCHES A DERIVE BY FULL NAMESPACE
  # THEN remove it from state.req
  # ELSE IF IT IS SPECIFIED BY NAMESPACE
  # THEN add it to a list of all invalid ops (errors)
  # ELSE add it to a list of ops belonging solely to self
  parseOps = ops: req: let
    reqPaths =
      req
      |> mapAttrs (name: let
        segs = parseClassSig name;
      in
        value: segs ++ [value]);

    # XXX: TODO: having to specify the full namespace sucks :(

    matches = partition (flipCurry hasAttrAt ops) reqPaths;

    pathsMissing = matches.wrong;
    opsSelf = removeAttrsRec matches.right ops;
    opsDerived = removeAttrsRec matches.wrong ops;
  in {
    inherit opsSelf opsDerived pathsMissing;
    success = length pathsMissing == 0;
  };

  mkClass = sig: decl:
    assert enfIsClassSig "mkClass" sig; let
      allDerivedClasses =
        decl.derive
        |> map (class: typeSig class ++ class.${ntTrapdoorKey}.derive);

      parseResult = parseOps decl.ops decl.req;
      inherit
        (parseResult)
        opsSelf
        opsDerived
        ;
    in
      # XXX: WARNING: classes currently *shouldn't* be able to inherit ops (i think?)
      assert parseResult.success || throw "TODO";
        mkTrapdoorSet {
          default = opsSelf;
          unlock = {
            # TODO: rename derive to deriveSigs (EXCEPT in the classDecl)
            ${ntTrapdoorKey} = {
              inherit sig;
              derive = allDerivedClasses;
              ops = {${sig} = opsSelf;} // opsDerived;
              req = null; # XXX: TODO make it more advanced
            };
          };
        };
in rec {
  # check if a value is an nt type/class
  isNT = T: let
    content = openTrapdoorFn ntTrapdoorKey T;
    names = attrNames content;
  in
    isAttrs content
    && all (name: elem name names) ["sig" "derive" "ops" "req"];

  isNixClass = T: let
    content = openTrapdoorFn ntTrapdoorKey T;
  in
    isAttrs content
    && attrNames content == ["sig" "derive" "ops" "req"];

  isNixType = T: let
    content = openTrapdoorFn ntTrapdoorKey T;
  in
    isAttrs content
    && attrNames content == ["instance" "sig" "derive" "ops" "req"]
    && content.instance == false;

  isNixTypeInstance = T: let
    content = openTrapdoorFn ntTrapdoorKey T;
  in
    isAttrs content
    && attrNames content == ["instance" "sig" "derive" "ops" "req"]
    && content.instance == true;

  # check if a type/class implements a signature
  # NOTE: unsafe variant, use typeSig if you can't guarantee `isNT T` holds
  impls' = type: T: elem (toTypeSig type) T.${ntTrapdoorKey}.derive;

  # NOTE safe variant, use impls' if you can guarantee `isNT T` holds
  impls = type: T: assert enfIsNT "nt.impls" T; impls' type T;

  # check if a type/class implements a signature
  # NOTE: unsafe variant, use `is` if you can't guarantee `isNT T` holds
  is' = type: T: T.${ntTrapdoorKey}.sig == toTypeSig type;

  # NOTE safe variant, use `is'` if you can guarantee `isNT T` holds
  is = type: T: assert enfIsNT "nt.is" T; is' type T;

  Class = sig: builder:
    recdef (Self:
      unwrapBuilder builder Self
      |> parseDecl classDecl
      |> mkClass sig);
}
