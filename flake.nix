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
      # Reuse the same nix-darwin revision for agenix's Darwin module graph.
      inputs.darwin.follows = "darwin";
    };
    # nix-darwin drives macOS system configuration.
    darwin.url = "github:lnl7/nix-darwin/master";
    doomemacs = {
      url = "github:doomemacs/doomemacs";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, agenix, darwin, doomemacs, ... }:
    let
      inherit (nixpkgs.lib) nixosSystem;
      inherit (darwin.lib) darwinSystem;
      mkHome = { hmConfig, system ? "x86_64-linux" }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          modules = [ hmConfig ];
          extraSpecialArgs = {
            inherit doomemacs;
          };
        };
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
              }
            ]);
        };
      # Helper for Darwin hosts (separate from NixOS module system).
      mkDarwinHost = { modules, hmConfig ? null, system ? "aarch64-darwin" }:
        darwinSystem {
          inherit system;
          modules =
            [
              agenix.darwinModules.default
            ]
            ++ modules
            ++ (if hmConfig == null then [ ] else [
              # Integrate Home Manager as a nix-darwin module.
              home-manager.darwinModules.home-manager
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

        server = mkHost {
          modules = [
            ./modules/homelab
            ./hosts/server/default.nix
          ];
        };
      };

      darwinConfigurations = {
        # Local MacBook target: `darwin-rebuild switch --flake .#macbook`
        macbook = mkDarwinHost {
          modules = [
            ./hosts/macbook/default.nix
          ];
          hmConfig = ./homes/macbook.nix;
        };
      };

      homeConfigurations = {
        wsl-ubuntu = mkHome {
          hmConfig = ./homes/wsl-ubuntu.nix;
        };
      };
    };
}
