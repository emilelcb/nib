{nib, ...} @ args: let
  attrs = import ./attrs.nix args;
  fault = import ./fault.nix args;
  lists = import ./lists.nix args;
  result = import ./result.nix args;
in
  attrs.mergeAttrsList [
    # submodule is included directly to this module (ie self.myFunc)
    attrs
    fault
    lists
    result

    # submodule content is accessible first by submodule name
    # then by the name of the content (ie self.submodule.myFunc)
  ]
