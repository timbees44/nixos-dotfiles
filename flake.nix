{
  description = "Hyprland on Nixos";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, agenix, lanzaboote, ... }:
    let
      inherit (nixpkgs.lib) nixosSystem;
      baseModules = [
        agenix.nixosModules.default
        ./modules/shared
      ];
      mkHost = { modules, primaryUser, linuxHome ? "/home/${primaryUser}", hmConfig ? null, system ? "x86_64-linux" }:
        nixosSystem {
          inherit system;
          specialArgs = {
            inherit primaryUser linuxHome;
          };
          modules =
            baseModules
            ++ modules
            ++ (if hmConfig == null then [ ] else [
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.${primaryUser} = import hmConfig;
                  backupFileExtension = "backup";
                  extraSpecialArgs = {
                    inherit primaryUser linuxHome;
                  };
                };
              }
            ]);
        };
    in {
      nixosConfigurations = {
        laptop = mkHost {
          primaryUser = "tim";
          modules = [
            ./hosts/laptop/default.nix
          ];
          hmConfig = ./homes/laptop.nix;
        };

        horus = mkHost {
          primaryUser = "tim";
          modules = [
            lanzaboote.nixosModules.lanzaboote
            ./hosts/horus/default.nix
          ];
          hmConfig = ./homes/horus.nix;
        };

        eisenstein = mkHost {
          primaryUser = "tim";
          modules = [
            ./modules/homelab
            ./hosts/server/default.nix
          ];
        };
      };
    };
}
