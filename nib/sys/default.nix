{lib, ...}: let
  # XXX: TODO: Move these helper functions into their own modules
  listToTrivialAttrs = values:
    builtins.listToAttrs (builtins.map (x: {
        name = x;
        value = x;
      })
      values);

  attrVals = lib.attrsets.attrVals;
in rec {
  # REF: https://github.com/nix-systems/nix-systems
  archs = listToTrivialAttrs arch;
  arch = [
    "x86_64"
    "aarch64"
    "riscv64"
  ];

  # REF: https://github.com/nix-systems/nix-systems
  platforms = listToTrivialAttrs platform;
  platform = [
    "linux"
    "darwin"
  ];

  # Nix System Identifier Lists - Default Supported Systems
  systems = systemsDefault;
  systemsDefault = systemsX86_64 // systemsAArch64;

  # Nix System Identifier Lists - All Potential Systems
  systemsAll = listsToSystemNames archs platforms;

  # Nix System Identifier Lists - Platform Specific
  systemsLinux = listsToSystemNames archs [platform.linux];
  systemsDarwin = listsToSystemNames archs [platform.darwin];

  # Nix System Identifier Lists - Architecture Specific
  systemsX86_64 = listsToSystemNames [arch.x86_64] platforms;
  systemsAArch64 = listsToSystemNames [arch.aarch64] platforms;
  systemsRiscV64 = listsToSystemNames [arch.riscv64] platforms;

  # === Internal Helper Functions ===
  toSystemName = arch: platform: "${arch}-${platform}";
  listsToSystemNames = archs: platforms:
    lib.lists.crossLists (arch: platform: toSystemName arch platform)
    [
      (attrVals archs)
      (attrVals platforms)
    ];

  # === External Functions ===
  # TODO
}
