{ primaryUser, linuxHome, dotfilesRoot, ... }:
{
  imports = [
    ../modules/home/dotfiles.nix
    ../modules/home/gpg.nix
    ../modules/home/packages.nix
  ];

  home.username = primaryUser;
  home.homeDirectory = linuxHome;
  home.stateVersion = "24.05";
  xdg.enable = true;

  my.dotfiles.root = dotfilesRoot;
}
