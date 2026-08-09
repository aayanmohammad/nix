{ pkgs, ... }:

{
  programs.git.enable = true;

  home.packages = with pkgs; [
    openssh
    less
  ];

  home.file.".gitconfig".source = ../configs/.gitconfig;
}

