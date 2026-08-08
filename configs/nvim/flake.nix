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

      system = machineConfig.system;

      pkgs = import nixpkgs {
        inherit system;
      };

      homeConfig = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ../../modules/nvim.nix

          {
            home = {
              username = machineConfig.username;
              homeDirectory = machineConfig.homeDirectory;
              stateVersion = "26.05";
            };

            xdg.configFile."nvim".source = ./.;
          }
        ];

        extraSpecialArgs = {
          machine = machineConfig;
        };
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          homeConfig.config.programs.neovim.finalPackage
        ];

        shellHook = ''
          export XDG_CONFIG_HOME="$PWD/.."
        '';
      };
    };
}

