{ config, lib, pkgs, ... }:

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

  # Decrypt agenix secrets using this machine's age identity key.
  age.identityPaths = [ "/home/tim/.config/age/keys.txt" ];
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

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.displayManager.defaultSession = "hyprland-uwsm";
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };
  services.udisks2.enable = true;
  services.gvfs.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  security.polkit.enable = true;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ vulkan-validation-layers ];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    powerManagement.enable = false;
    open = false;
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
    pkg-config
    libtool
    unzip
    gnutar
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.05";
}
