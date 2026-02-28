{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    adwaita-icon-theme
    gnome-themes-extra
  ];

  gtk = {
    enable = true;
    theme.name = "Adwaita";
    iconTheme.name = "Adwaita";
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };
  };

}
