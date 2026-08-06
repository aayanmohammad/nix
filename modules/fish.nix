{ ... }:

{
  programs.fish.enable = true;

  xdg.configFile."fish" = {
    source = ../configs/fish;
    recursive = true;
  };
}

