# SPDX-FileCopyrightText: 2023 Mikaela Allan
#
# SPDX-License-Identifier: GPL-3.0-or-later
{
  # Haumea Arguments
  self,
  super,
  root,
  # Hive/Std/Paisano Arguments
  inputs,
  cell,
  ...
}: let
  pkgs = cell.packages.default;
in {
  colorscheme = "base16-scheme";

  extraPackages = [
    pkgs.git
  ];

  extraPlugins = [
    pkgs.vimPlugins.base16-vim
    pkgs.vimPlugins.direnv-vim
  ];

  options = {
    number = true;
    signcolumn = "auto:2-5";
  };

  plugins = {
    bufferline.enable = true;
    neogit.enable = true;
    nix.enable = true;
  };
}
