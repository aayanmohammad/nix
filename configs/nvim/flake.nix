{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    machine = {
      url = "path:/etc/nix/machine.nix";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      machine,
      ...
    }:
    let
      machineConfig = import machine;

      pkgs = import nixpkgs {
        system = machineConfig.system;
      };

      neovimConfig = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          machine = machineConfig;
        };

        modules = [
          ../../modules/nvim.nix

          {
            home = {
              username = machineConfig.username;
              homeDirectory = machineConfig.homeDirectory;
              stateVersion = "26.05";
            };
          }
        ];
      };
    in
    {
      devShells.${machineConfig.system}.default = pkgs.mkShell {
        packages = [
          neovimConfig.config.programs.neovim.finalPackage
        ];

        shellHook = ''
          export XDG_CONFIG_HOME="$PWD/.."
        '';
      };
    };
}

