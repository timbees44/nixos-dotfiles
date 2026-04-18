{ config, pkgs, lib, ... }:
let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;

  configs = {
    hypr = "hypr";
    foot = "foot";
    nvim = "nvim";
    starship = "starship";
    swaylock = "swaylock";
    tmux = "tmux";
  };
in
{
  imports = [
    ../modules/theme.nix
  ];

  home.username = "tim";
  home.homeDirectory = "/home/tim";
  home.stateVersion = "24.05";
  xdg.enable = true;

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };

  home.packages = (with pkgs; [
    bat
    bluez
    bluetui
    brave
    btop
    cmake
    codex
    curl
    deluge
    element-desktop
    emacs
    eza
    fd
    foot
    fzf
    gcc
    gnumake
    hypridle
    hyprpaper
    isync
    jq
    msmtp
    neovim
    nitch
    nixpkgs-fmt
    pcmanfm
    ripgrep
    starship
    swaylock-effects
    tmux
    tree
    wmenu
    zoxide
    (pkgs.writeShellApplication {
      name = "ns";
      runtimeInputs = with pkgs; [
        fzf
        nix-search-tv
      ];
      text = ''exec "${pkgs.nix-search-tv.src}/nixpkgs.sh" "$@"'';
    })
  ]);

  home.file.".bashrc" = {
    source = create_symlink "${dotfiles}/bash/.bashrc";
  };

  home.file.".bash_profile" = {
    source = create_symlink "${dotfiles}/bash/.bash_profile";
  };

  xdg.configFile = builtins.mapAttrs
    (_name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs;

  home.file."pictures/walls/.keep" = {
    text = "";
  };

  home.file."pictures/walls/prometheus.png" = {
    source = create_symlink "${dotfiles}/walls/prometheus.png";
  };

  home.activation.ensureBootstrapDirs = lib.hm.dag.entryBefore [ "dconfSettings" ] ''
    mkdir -p "$HOME/.config/dconf" "$HOME/.config/age" "$HOME/.config/isync" "$HOME/.config/msmtp"
  '';

  # Keep Horus on bare Emacs by moving any existing Doom trees out of the way.
  home.activation.disableDoom = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if [ -x "$HOME/.emacs.d/bin/doom" ]; then
      backup="$HOME/.emacs.d.doom-backup"
      if [ -e "$backup" ]; then
        backup="$backup-$(date +%s)"
      fi
      mv "$HOME/.emacs.d" "$backup"
    fi

    if [ -e "$HOME/.config/doom" ] || [ -L "$HOME/.config/doom" ]; then
      backup="$HOME/.config/doom.backup"
      if [ -e "$backup" ]; then
        backup="$backup-$(date +%s)"
      fi
      mv "$HOME/.config/doom" "$backup"
    fi
  '';
}
