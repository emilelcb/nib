{
  nib,
  # typespace,
  ...
}: let
  inherit
    (nib)
    Attrs
    Bool
    contains
    expect
    flipCurry
    Fn
    getHidden
    Meta
    PartialOrder
    Prod
    Sum
    Type
    Class
    UnFn # UnFn = Fn Any Any
    ;
in {
  # Rose = Struct "nib::Rose" (Rose: {
  Rose = Type "nib::Rose" (Self: {
    ops = {
      # elements can either be an attribute set, or a function/lambda
      # roses :: [Rose]
      Type.mk = meta: roses: {
        expose = roses;
        hidden = {inherit meta;};
      };

      PartialOrder.leq = flipCurry contains;

      Meta.get = R: (getHidden R).meta;
    };

    derive = [
      PartialOrder
      Meta
    ];
  });

  PartialOrder = Class "nib::&PartialOrder" (Self: {
    ops = {
      # NOTE: `Prod A B` == `Prod [A B]`
      leq = expect <| Fn (Prod Self Self) Bool;
      gt = ! Self.leq;
    };
  });

  Meta = Class "nib::&Meta" {
    # NOTE: `Sum A B` == `Sum [A B]`
    attrs.hidden.meta = expect <| Sum [UnFn Attrs];
    ops.get = T: (getHidden T).meta;
  };

  ProperType = Class "nib::&ProperType" (Self: {
    ops.mk = expect <| Sum [UnFn Self];
  });

  Trivial =
    Class "nib::&Trivial" {
    };

  # We can now do the following:
  # `Rose.mk meta [...]` <-> `Rose meta [...]`
  # Rose.leq roseA roseB
  # Rose.meta roseA
  # Rose.verify # Verify all Axioms

  # in Cerulean: (Nix-style type extensions via overlays/overrides)
  # Group = nib.overrideStruct Rose (prev: { ... });
}
