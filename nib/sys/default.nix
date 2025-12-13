{lib, ...}: let
  # XXX: TODO: Move these helper functions into their own modules
  listToTrivialAttrs = values:
    builtins.listToAttrs (builtins.map (x: {
        name = x;
        value = x;
      })
      values);
in rec {
  # REF: https://github.com/nix-systems/nix-systems
  archs = listToTrivialAttrs [
    "x86_64"
    "aarch64"
    "riscv64"
  ];

  # REF: https://github.com/nix-systems/nix-systems
  platforms = listToTrivialAttrs [
    "linux"
    "darwin"
  ];

  # Nix System Identifier Lists - Default Supported Systems
  # systems = systemsDefault;
  systems.default = systems.x86_64 // systems.aarch64;

  # Nix System Identifier Lists - All Potential Systems
  systems.all = listsToSystemNames archs platforms;

  # Nix System Identifier Lists - Platform Specific
  systems.linux = listsToSystemNames archs [platforms.linux];
  systems.darwin = listsToSystemNames archs [platforms.darwin];

  # Nix System Identifier Lists - Architecture Specific
  systems.x86_64 = listsToSystemNames [archs.x86_64] platforms;
  systems.aarch64 = listsToSystemNames [archs.aarch64] platforms;
  systems.riscv64 = listsToSystemNames [archs.riscv64] platforms;

  # === Internal Helper Functions ===
  toSystemName = arch: platform: "${arch}-${platform}";
  listsToSystemNames = archs: platforms:
    lib.lists.crossLists (arch: platform: toSystemName arch platform)
    (with lib.attrsets; [
      (attrValues archs)
      (attrValues platforms)
    ]);

  # === External Functions ===
  # TODO
}
