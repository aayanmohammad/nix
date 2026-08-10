{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    machine = {
      url = "path:/etc/nix/machine.nix";
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
    in
    {
      homeConfigurations = {
        ${machineConfig.username} = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [ ./home.nix ];

          extraSpecialArgs = {
            machine = machineConfig;
          };
        };
      };
    };
}

