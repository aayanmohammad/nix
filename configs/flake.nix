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

      configHome = "${machineConfig.homeDirectory}/.nix/configs";

      pkgs = import nixpkgs {
        system = machineConfig.system;
      };

      homeManager = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          machine = machineConfig;
        };

        modules = [
          ../home.nix
          {
            xdg.configHome = configHome;
          }
        ];
      };
    in
    {
      devShells.${machineConfig.system}.default = pkgs.mkShell {
        packages = homeManager.config.home.packages;
        shellHook = ''
          export HOME="${configHome}"
          export XDG_CONFIG_HOME="${configHome}"

          export XDG_CACHE_HOME="${machineConfig.homeDirectory}/.cache"
          export XDG_DATA_HOME="${machineConfig.homeDirectory}/.local/share"
          export XDG_STATE_HOME="${machineConfig.homeDirectory}/.local/state"
        '';
      };
    };
}

