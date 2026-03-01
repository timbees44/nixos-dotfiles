{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "server";
  time.timeZone = "Europe/London";

  users.users.tim = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  services.openssh.enable = true;

  system.stateVersion = "24.05";
}
