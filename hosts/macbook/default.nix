{ pkgs, ... }:
{
  networking.hostName = "laptop";

  users.users.tim.home = "/Users/tim";
  ids.gids.nixbld = 350;

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "tim" ];
      warn-dirty = false;
    };

    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 3;
        Minute = 15;
      };
      options = "--delete-older-than 7d";
    };

    optimise.automatic = true;
  };

  nix.enable = true;
  programs.zsh.enable = true;

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
  ];

  system.primaryUser = "tim";

  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain = {
      AppleInterfaceStyleSwitchesAutomatically = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };
  };

  system.stateVersion = 4;
}
