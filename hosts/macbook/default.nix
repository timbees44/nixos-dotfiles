{ pkgs, ... }:
{
  # Hostname shown in macOS sharing/network panes.
  networking.hostName = "laptop";

  # Keep user path explicit for Darwin module defaults.
  users.users.tim.home = "/Users/tim";
  # Match existing local Nix install's nixbld group ID.
  ids.gids.nixbld = 350;

  # Decrypt agenix secrets using this machine's age identity key.
  age.identityPaths = [ "/Users/tim/.config/age/keys.txt" ];
  age.secrets = {
    mbsyncrc = {
      file = ../../secrets/mbsyncrc.age;
      path = "/Users/tim/.config/isync/mbsyncrc";
      owner = "tim";
      group = "staff";
      mode = "0400";
    };
    msmtp-config = {
      file = ../../secrets/msmtp-config.age;
      path = "/Users/tim/.config/msmtp/config";
      owner = "tim";
      group = "staff";
      mode = "0400";
    };
  };

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
    cmake
    fd
    fzf
    git
    neovim
    nmap
    nodejs
    openvpn
    sqlite
    vim
    wget
  ];

  # Declarative Homebrew management via nix-darwin.
  # Keep cleanup off until brews/casks are fully mirrored here.
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "none";
    };

    taps = [
      "d12frosted/emacs-plus"
      "felixkratz/formulae"
      "nikitabobko/tap"
    ];
    # Keep only Brew-specific packages here; prefer nixpkgs for CLI tools.
    brews = [
      "d12frosted/emacs-plus/emacs-plus@30"
      "felixkratz/formulae/sketchybar"
      "isync"
      "mu"
    ];
    casks = [
      "anki"
      "codex"
      "karabiner-elements"
      "mos"
      "nikitabobko/tap/aerospace"
      "skim"
      "tailscale-app"
      "vlc"
    ];
    masApps = { };
  };

  # Start Karabiner-Elements at login.
  launchd.user.agents.karabiner-elements = {
    serviceConfig = {
      Label = "local.karabiner-elements";
      ProgramArguments = [
        "/usr/bin/open"
        "-a"
        "Karabiner-Elements"
      ];
      KeepAlive = false;
      RunAtLoad = true;
      StandardOutPath = "/tmp/karabiner-elements.out.log";
      StandardErrorPath = "/tmp/karabiner-elements.err.log";
    };
  };

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
