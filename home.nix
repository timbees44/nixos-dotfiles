{ config, pkgs, ... }:
let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  tokyoNightLock = "${config.home.homeDirectory}/pictures/walls/tokyonight-lock.jpg";

  configs = {
    hypr = "hypr";
    nvim = "nvim";
    rofi = "rofi";
    waybar = "waybar";
  };
in
{
  imports = [
    ./modules/theme.nix
  ];

  home.username = "tim";
  home.homeDirectory = "/home/tim";
  home.stateVersion = "24.05";
  programs.bash = {
    enable = true;
    shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake ~/nixos-dotfiles#nixos";
      vi = "nvim";
      vim = "nvim";
    };
    profileExtra = ''
      if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
        exec uwsm start -S hyprland-uwsm.desktop
      fi
    '';
  };

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      clock = true;
      datestr = "%a, %d %b";
      font = "JetBrainsMono Nerd Font";
      image = tokyoNightLock;
      indicator = true;
      "indicator-radius" = 160;
      "indicator-thickness" = 12;
      "inside-color" = "1a1b26dd";
      "inside-clear-color" = "1a1b26dd";
      "inside-ver-color" = "1a1b26dd";
      "line-color" = "00000000";
      "ring-color" = "7aa2f7ff";
      "ring-clear-color" = "7dcfffaa";
      "ring-ver-color" = "7aa2f7ff";
      "ring-wrong-color" = "f7768eff";
      "text-color" = "c0caf5ff";
      "text-clear-color" = "c0caf5ff";
      "text-ver-color" = "c0caf5ff";
      "text-wrong-color" = "f7768eff";
      "key-hl-color" = "bb9af7ff";
      "bs-hl-color" = "f7768eff";
      "separator-color" = "00000000";
      "grace" = 0;
      "fade-in" = 0;
      "effect-blur" = "4x2";
      scaling = "fill";
      color = "00000000";
    };
  };
  services.swayidle = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    events = [
      {
        event = "before-sleep";
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
      {
        event = "lock";
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
    ];
    timeouts = [
      {
        timeout = 300;
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
      {
        timeout = 600;
        command = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
        resumeCommand = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      }
    ];
  };

  home.packages = with pkgs; [
    codex
    foot
    gcc
    hyprpaper
    kitty
    neovim
    nitch
    nixpkgs-fmt
    opencode
    pcmanfm
    ripgrep
    tree
    waybar
    wofi
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
