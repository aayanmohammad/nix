{ pkgs, ... }:

{
  programs.git.enable = true;

  home.packages = with pkgs; [ openssh ];

  home.file.".gitconfig".source = ../configs/.gitconfig;
}

