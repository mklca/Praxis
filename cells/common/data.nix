# SPDX-FileCopyrightText: 2023 Mikaela Allan
#
# SPDX-License-Identifier: GPL-3.0-or-later
{
  inputs,
  cell,
}: let
  l = inputs.nixpkgs.lib // builtins;
in {
  nix = {
    registry = {
      impermanence = {
        from = {
          id = "impermanence";
          type = "indirect";
        };

        to = {
          type = "github";
          owner = "nix-community";
          repo = "impermanence";
        };
      };

      nixos-generators = {
        from = {
          id = "nixos-generators";
          type = "indirect";
        };

        to = {
          type = "github";
          owner = "nix-community";
          repo = "nixos-generators";
        };
      };
    };

    substituters = [
      "https://cache.iog.io"
    ];

    trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
  };

  theme.base16.schemeName = "catppuccin-mocha";

  users.authorizedKeys =
    l.mapAttrs
    (user: l.map (pk: "${pk.type} ${pk.publicKey} ${pk.comment or "mklca-${user}"}"))
    inputs.cells.auth.data.sshPublicKeys.users;
}
