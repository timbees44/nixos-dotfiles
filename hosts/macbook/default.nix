{ pkgs, ... }:
{
  # Hostname shown in macOS sharing/network panes.
  networking.hostName = "laptop";

  # Keep user path explicit for Darwin module defaults.
  users.users.tim.home = "/Users/tim";
  # Match existing local Nix install's nixbld group ID.
  ids.gids.nixbld = 350;

  # Core Nix daemon/client behavior on macOS.
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "tim" ];
      warn-dirty = false;
    };

    # Housekeeping for store growth.
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

  # Evaluate packages for Apple Silicon and allow unfree software.
  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
  };

  # Allow Touch ID for sudo in local terminal sessions.
  security.pam.services.sudo_local.touchIdAuth = true;

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
  ];

  # Required by newer nix-darwin for user-scoped defaults writes.
  system.primaryUser = "tim";

  # Opinionated macOS defaults managed declaratively.
  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain = {
      AppleInterfaceStyleSwitchesAutomatically = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };
  };

  # Keep in sync with nix-darwin migration guidance.
  system.stateVersion = 4;
}
