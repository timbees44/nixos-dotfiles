{
  imports = [
    ./linux-desktop.nix
    ../modules/home/packages-hyprland.nix
  ];

  my.dotfiles.extraConfigs = {
    hypr = "hypr";
    swaylock = "swaylock";
  };
}
