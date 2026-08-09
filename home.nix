{ machine, ... }:

{
  imports = [
    ./modules/git.nix
    ./modules/fish.nix
    ./modules/nvim.nix
    ./modules/ollama.nix
  ];

  programs.home-manager.enable = true;

  home = {
    username = machine.username;
    homeDirectory = machine.homeDirectory;

    stateVersion = "26.05";
  };
}

