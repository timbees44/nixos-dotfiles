{
  description = "Hyprland on Nixos";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
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
      baseModules = [
        agenix.nixosModules.default
        ./modules/shared
      ];
      mkHost = { modules, hmConfig ? null, system ? "x86_64-linux" }:
        nixosSystem {
          inherit system;
          modules =
            baseModules
            ++ modules
            ++ (if hmConfig == null then [ ] else [
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  users.tim = import hmConfig;
                  backupFileExtension = "backup";
                  extraSpecialArgs = {
                    inherit doomemacs;
                  };
                };
                systemd.services."home-manager-tim".serviceConfig.Environment = [
                  "XDG_RUNTIME_DIR=/run/user/1000"
                ];
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

        server = mkHost {
          modules = [
            ./modules/homelab
            ./hosts/server/default.nix
          ];
        };
      };
    };
}
