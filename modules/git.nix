{ ... }:

{
  programs.git.enable = true;

  home.file.".gitconfig".source = ../configs/git/.gitconfig;
}

