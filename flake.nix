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
    doomemacs = {
      url = "github:doomemacs/doomemacs";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, agenix, doomemacs, ... }:
    let
      inherit (nixpkgs.lib) nixosSystem;
      primaryUser = "tim";
      linuxHome = "/home/${primaryUser}";
      mkHome = { hmConfig, system ? "x86_64-linux" }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          modules = [ hmConfig ];
          extraSpecialArgs = {
            inherit doomemacs primaryUser linuxHome;
          };
        };
      baseModules = [
        agenix.nixosModules.default
        ./modules/shared
      ];
      mkHost = { modules, hmConfig ? null, system ? "x86_64-linux" }:
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
                    inherit doomemacs primaryUser linuxHome;
                  };
                };
              }
            ]);
        };
    in {
      nixosConfigurations = {
        laptop = mkHost {
          modules = [
            ./hosts/laptop/default.nix
          ];
          hmConfig = ./homes/laptop.nix;
        };

        horus = mkHost {
          modules = [
            ./hosts/horus/default.nix
          ];
          hmConfig = ./homes/horus.nix;
        };

        eisenstein = mkHost {
          modules = [
            ./modules/homelab
            ./hosts/server/default.nix
          ];
        };
      };

      homeConfigurations = {
        legion = mkHome {
          hmConfig = ./homes/wsl-ubuntu.nix;
        };
      };
    };
}
