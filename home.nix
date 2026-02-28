{ config, pkgs, ... }:
let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;

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

}
