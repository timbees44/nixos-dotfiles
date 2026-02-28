{ config, pkgs, ... }:
let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;

  configs = {
    doom = "doom";
    hypr = "hypr";
    nvim = "nvim";
    starship = "starship";
    tmux = "tmux";
    waybar = "waybar";
    wezterm = "wezterm";
    wofi = "wofi";
    swaylock = "swaylock";
  };
in
{
  imports = [
    ./modules/theme.nix
  ];

  home.username = "tim";
  home.homeDirectory = "/home/tim";
  home.stateVersion = "24.05";

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };

  services.swayidle = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    events = [
      {
        event = "before-sleep";
        command = "${pkgs.swaylock-effects}/bin/swaylock -f";
      }
      {
        event = "lock";
        command = "${pkgs.swaylock-effects}/bin/swaylock -f";
      }
    ];
    timeouts = [
      {
        timeout = 300;
        command = "${pkgs.swaylock-effects}/bin/swaylock -f";
      }
      {
        timeout = 600;
        command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
        resumeCommand = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      }
    ];
  };

  home.packages = with pkgs; [
    bat
    codex
    eza
    foot
    fzf
    gcc
    hyprpaper
    neovim
    nitch
    nixpkgs-fmt
    opencode
    pcmanfm
    ripgrep
    starship
    swaylock-effects
    tmux
    tree
    waybar
    wezterm
    wofi
    zoxide
    emacs
    (pkgs.writeShellApplication {
      name = "ns";
      runtimeInputs = with pkgs; [
        fzf
        (nix-search-tv.overrideAttrs {
          env.GOEXPERIMENT = "jsonv2";
        })
      ];
      text = ''exec "${pkgs.nix-search-tv.src}/nixpkgs.sh" "$@"'';
    })
  ];

  home.file.".bashrc" = {
    source = create_symlink "${dotfiles}/bash/.bashrc";
  };

  home.file.".bash_profile" = {
    source = create_symlink "${dotfiles}/bash/.bash_profile";
  };

  xdg.configFile = builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs;

  home.file."pictures/walls/.keep" = {
    text = "";
  };

}
