{ pkgs, lib, ... }:
{
  imports = [ ./hyprland.nix ];

  my.dotfiles.extraConfigs = {
    waybar = "waybar";
    wezterm = "wezterm";
    wofi = "wofi";
  };

  home.packages =
    (with pkgs; [
      mu
      waybar
      wezterm
      wofi
    ])
    ++ lib.optionals (pkgs.mu ? emacs) [ pkgs.mu.emacs ]
    ++ lib.optionals (pkgs ? mu4e) [ pkgs.mu4e ];
}
