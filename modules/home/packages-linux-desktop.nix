{ pkgs, ... }:
{
  # Graphical and Linux integration tools shared by the NixOS desktops.
  # Other desktops can opt into these as their OS boundary becomes clear.
  home.packages = with pkgs; [
    bluetui
    brave
    deluge
    nitch
    pcmanfm
  ];
}
