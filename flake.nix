{
  description = "Hyprland on Nixos";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    doomemacs = {
      url = "github:doomemacs/doomemacs";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.tim = import ./home.nix;
            backupFileExtension = "backup";
            extraSpecialArgs = {
              inherit (inputs) doomemacs;
            };
          };
          systemd.services."home-manager-tim".serviceConfig.Environment = [
            "XDG_RUNTIME_DIR=/run/user/1000"
          ];
        }
      ];
    };
  };
}
