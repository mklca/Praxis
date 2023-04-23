{
  inputs,
  cell
}:
let
  inherit (inputs) nixpkgs;
  inherit (inputs.std) std;
  inherit (inputs.std.lib.dev) mkShell;
  inherit (nixpkgs.lib.attrsets) mapAttrs;
  inherit (nixpkgs.lib.trivial) const;
in mapAttrs (const mkShell) {
  default = { config, lib, ... }: {
    imports = [
      std.devshellProfiles.default
    ];

    name = "Praxis";

    devshell = {
      name = lib.mkForce "praxis-shell";
      meta.description = "Main development shell for the Praxis project";
    };
  };
}
