{ lib, pkgs, primaryUser, linuxHome, ... }:
{
  imports = [
    ../../modules/shared/mail-secrets.nix
    ../../modules/nixos/profiles/hyprland.nix
    ../../modules/nixos/profiles/nvidia-desktop.nix
    ../../modules/nixos/profiles/workstation.nix
  ] ++ lib.optional (builtins.pathExists ./hardware-configuration.nix)
    ./hardware-configuration.nix;

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.timeout = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  networking.hostName = "horus";
  networking.firewall.allowedTCPPorts = [ 11434 ];
  programs.dconf.enable = true;
  programs.gamescope.enable = true;
  programs.steam.enable = true;
  programs.gamemode.enable = true;
  hardware.steam-hardware.enable = true;
  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    port = 11434;
  };
  services.syncthing = {
    enable = true;
    user = primaryUser;
    dataDir = "${linuxHome}/syncthing";
    configDir = "${linuxHome}/.config/syncthing";
    guiAddress = "127.0.0.1:8384";
    openDefaultPorts = true;
  };
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  security.rtkit.enable = true;
  security.pam.services.swaylock = { };

  users.users.${primaryUser}.shell = pkgs.bashInteractive;

  environment.systemPackages = with pkgs; [
    sbctl
    pciutils
    bluez
    bluez-tools
  ];

  system.stateVersion = "24.05";
}
