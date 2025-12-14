{nib, ...}:
with nib.types; let
  # === Internal Helper Functions ===
  toSystemName = arch: platform: "${arch}-${platform}";
  listsToSystemNames = archs: platforms:
    crossLists (arch: platform: toSystemName arch platform)
    [
      (builtins.attrValues archs)
      (builtins.attrValues platforms)
    ];
in rec {
  # REF: https://github.com/nix-systems/nix-systems
  archs = identityAttrsList [
    "x86_64"
    "aarch64"
    "riscv64"
  ];

  # REF: https://github.com/nix-systems/nix-systems
  platforms = identityAttrsList [
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
}
