{ config, pkgs, lib, primaryUser, linuxHome, ... }:
import ./common.nix {
  inherit config pkgs lib primaryUser linuxHome;

  extraConfigs = {
    foot = "foot";
  };

  extraPackages = with pkgs; [
    basedpyright
    bluez
    codex-acp
    curl
    discord
    element-desktop
    foot
<<<<<<< HEAD
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
    ollama
    pcmanfm
=======
>>>>>>> 14eef96 (clean up)
    python3
    ruff
    wmenu
  ];

  extraFiles = {
    "pictures/walls/prometheus.png".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/projects/nixos-dotfiles/config/walls/prometheus.png";
  };
}
