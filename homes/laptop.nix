{ config, pkgs, lib, primaryUser, linuxHome, ... }:
import ./common.nix {
  inherit config pkgs lib primaryUser linuxHome;

  extraConfigs = {
    waybar = "waybar";
    wezterm = "wezterm";
    wofi = "wofi";
  };

  extraPackages =
    (with pkgs; [
      mu
      waybar
      wezterm
      wofi
    ])
    ++ lib.optionals (pkgs.mu ? emacs) [ pkgs.mu.emacs ]
    ++ lib.optionals (pkgs ? mu4e) [ pkgs.mu4e ];
}
