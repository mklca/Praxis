# SPDX-FileCopyrightText: 2023 Mikaela Allan
#
# SPDX-License-Identifier: GPL-3.0-or-later
{
  description = "Personal configurations and operations";

  inputs = {
    base16.url = github:SenchoPens/base16.nix;

    base16-schemes = {
      flake = false;
      url = github:tinted-theming/base16-schemes;
    };

    base16-vim = {
      flake = false;
      url = github:tinted-theming/base16-vim;
    };

    flake-utils.url = github:numtide/flake-utils;

    haumea.url = github:nix-community/haumea;

    hive = {
      url = github:divnix/hive;
      inputs = {
        haumea.follows = "haumea";
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
        paisano.follows = "paisano";
      };
    };

    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = github:nix-community/impermanence;

    lanzaboote = {
      url = github:nix-community/lanzaboote;
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };

    nix-darwin = {
      url = github:LnL7/nix-darwin;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = github:nix-community/nixos-generators;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = flake:nixos-hardware;

    nixpkgs.url = flake:nixpkgs;

    nixvim = {
      url = github:pta2002/nixvim;
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };

    paisano = {
      url = github:paisano-nix/core;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    std = {
      url = github:divnix/std;
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
        paisano.follows = "paisano";
      };
    };
  };

  outputs = {
    hive,
    paisano,
    std,
    ...
  } @ inputs:
    paisano.growOn {
      inherit inputs;

      cellsFrom = ./cells;

      cellBlocks = let
        inherit (std.blockTypes) data devshells functions nixago pkgs;
        inherit (hive.blockTypes) darwinConfigurations homeConfigurations nixosConfigurations;

        darwinModules = {
          name = "darwinModules";
          type = "darwinModule";
        };
        homeModules = {
          name = "homeModules";
          type = "homeModule";
        };

        nixosModules = {
          name = "nixosModules";
          type = "nixosModule";
        };

        nixvimConfigurations = {
          name = "nixvimConfigurations";
          type = "nixvimConfiguration";
        };
      in [
        (data "data")
        nixvimConfigurations
        (functions "overlays")
        (pkgs "packages")

        (devshells "shells")
        (nixago "pebbles")

        darwinConfigurations
        darwinModules
        homeConfigurations
        homeModules
        nixosConfigurations
        nixosModules
      ];

      systems = with inputs.flake-utils.lib.system; [
        x86_64-linux
        x86_64-darwin
      ];
    }
    (let
      collect' =
        hive.collect
        // {
          # Exports the target name directly
          renamer = with inputs.nixpkgs.lib.trivial; const id;
        };
    in {
      darwinConfigurations = collect' inputs.self "darwinConfigurations";
      devShells = paisano.harvest inputs.self ["main" "shells"];
      homeConfigurations = collect' inputs.self "homeConfigurations";
      nixosConfigurations = collect' inputs.self "nixosConfigurations";
    })
    {
      packages.x86_64-linux = {
        inherit (inputs.self.x86_64-linux.nixos-installer.packages) nixos-x86_64-installer-iso;
      };
    };
}
