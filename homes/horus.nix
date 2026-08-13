{ config, pkgs, ... }:
{
  imports = [ ./hyprland.nix ];

  my.dotfiles.extraConfigs = {
    foot = "foot";
  };

  home.packages = with pkgs; [
    basedpyright
    bluez
    codex-acp
    curl
    discord
    element-desktop
    foot
    ollama
    python3
    ruff
    wmenu
  ];

  home.file."pictures/walls/prometheus.png".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.my.dotfiles.root}/walls/prometheus.png";
}
