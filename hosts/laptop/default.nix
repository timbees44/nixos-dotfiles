{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };

  time.timeZone = "Europe/London";

  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.displayManager.defaultSession = "hyprland-uwsm";

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  users.users.tim = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    cmake
    gnumake
    gcc
    pkg-config
    libtool
    unzip
    gnutar
  ];

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };
  services.power-profiles-daemon.enable = true;

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  security.pam.services.swaylock = {};

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.05";

}
