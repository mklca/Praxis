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
  colorschemes.catppuccin = {
    enable = true;

    background = {
      dark = "mocha";
      light = "latte";
    };

    flavour = "mocha";

    integrations.cmp = true;
  };

  extraConfigLua = ''
    vim.g.exrc = true
  '';

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
    lsp = {
      enable = true;
      servers = {
        bashls.enable = true;
        clangd.enable = true;
        hls.enable = true;
        rnix-lsp.enable = true;
        yamlls.enable = true;
      };
    };
    lsp-lines.enable = true;
    luasnip.enable = true;
    nvim-cmp = {
      enable = true;

      mappingPresets = ["insert"];
      mapping = {
        "<C-Space>" = "cmp.mapping.complete()";

        # <C-b> (back) <C-f> (forward) for snippet placeholder navigation.
        "<C-u>" = "cmp.mapping.scroll_docs(-4)"; # Up
        "<C-d>" = "cmp.mapping.scroll_docs(4)"; # Down

        "<CR>" = ''
          cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }
        '';

        "<Tab>" = {
          modes = ["i" "s"];
          action = ''
            function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip and luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              else
                fallback()
              end
            end
          '';
        };

        "<S-Tab>" = {
          modes = ["i" "s"];
          action = ''
            function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip and luasnip.jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end
          '';
        };
      };

      snippet.expand = "luasnip";

      sources = [
        {name = "nvim_lsp";}
        {name = "luasnip";}
        {name = "path";}
        {name = "buffer";}
      ];
    };
  };
}
