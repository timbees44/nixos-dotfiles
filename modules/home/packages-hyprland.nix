{ pkgs, ... }:
{
  home.packages = with pkgs; [
    hypridle
    hyprpaper
    swaylock-effects
  ];
}
