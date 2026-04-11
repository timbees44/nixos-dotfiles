{ config, lib, pkgs, ... }:
let
  timAgeKey = "/home/tim/.config/age/keys.txt";
in

{
  imports = lib.optional (builtins.pathExists ./hardware-configuration.nix)
    ./hardware-configuration.nix;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "horus";
  networking.networkmanager = {
    enable = true;
    wifi = {
      powersave = false;
      backend = "wpa_supplicant";
    };
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  age.identityPaths = [ timAgeKey ];
  age.secrets = {
    mbsyncrc = {
      file = ../../secrets/mbsyncrc.age;
      path = "/home/tim/.config/isync/mbsyncrc";
      owner = "tim";
      group = "users";
      mode = "0400";
    };
    msmtp-config = {
      file = ../../secrets/msmtp-config.age;
      path = "/home/tim/.config/msmtp/config";
      owner = "tim";
      group = "users";
      mode = "0400";
    };
  };

  time.timeZone = "Europe/London";

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };
  programs.dconf.enable = true;
  programs.steam.enable = true;
  programs.gamemode.enable = true;
  hardware.steam-hardware.enable = true;
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  services.udisks2.enable = true;
  services.gvfs.enable = true;

  security.polkit.enable = true;
  security.rtkit.enable = true;
  security.pam.services.swaylock = { };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ vulkan-validation-layers ];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    powerManagement.enable = false;
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NVD_BACKEND = "direct";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  users.users.tim = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    cmake
    gnumake
    gcc
    pciutils
    bluez
    bluez-tools
    pkg-config
    libtool
    mangohud
    unzip
    gnutar
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.05";
}
