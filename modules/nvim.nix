{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;

    extraPackages = with pkgs; [
      stylua
      lua-language-server

      bash-language-server
      shfmt

      basedpyright
      black

      nixd
      nixfmt

      fish-lsp
    ];
  };

  xdg.configFile."nvim" = {
    source = ../configs/nvim;
    recursive = true;
  };
}

