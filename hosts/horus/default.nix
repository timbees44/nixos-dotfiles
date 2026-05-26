{ config, lib, pkgs, primaryUser, linuxHome, ... }:
let
  ageKeyPath = "${linuxHome}/.config/age/keys.txt";
  windowsEsp = "/dev/disk/by-partuuid/ad956a07-59cb-45e1-899a-ae54cedbdc29";
in

{
  imports = lib.optional (builtins.pathExists ./hardware-configuration.nix)
    ./hardware-configuration.nix;

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.timeout = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  networking.hostName = "horus";
  networking.networkmanager = {
    enable = true;
    wifi = {
      powersave = false;
      backend = "wpa_supplicant";
    };
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  age.identityPaths = [ ageKeyPath ];
  age.secrets = {
    mbsyncrc = {
      file = ../../secrets/mbsyncrc.age;
      path = "${linuxHome}/.config/isync/mbsyncrc";
      owner = primaryUser;
      group = "users";
      mode = "0400";
    };
    msmtp-config = {
      file = ../../secrets/msmtp-config.age;
      path = "${linuxHome}/.config/msmtp/config";
      owner = primaryUser;
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
  programs.gamescope.enable = true;
  programs.steam.enable = true;
  programs.gamemode.enable = true;
  hardware.steam-hardware.enable = true;
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
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

  users.users.${primaryUser} = {
    isNormalUser = true;
    shell = pkgs.bashInteractive;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    sbctl
    cmake
    gnumake
    gcc
    gparted
    pciutils
    bluez
    bluez-tools
    pkg-config
    libtool
    unzip
    gnutar
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.activationScripts.horusWindowsBootEntry.text = ''
    windows_esp_mount=/run/horus-windows-esp

    mkdir -p "$windows_esp_mount" /boot/EFI /boot/loader/entries

    if mountpoint -q "$windows_esp_mount"; then
      umount "$windows_esp_mount"
    fi

    if mount -o ro ${windowsEsp} "$windows_esp_mount"; then
      if [ -d "$windows_esp_mount/EFI/Microsoft" ]; then
        rm -rf /boot/EFI/Microsoft
        cp -r "$windows_esp_mount/EFI/Microsoft" /boot/EFI/
      fi
      umount "$windows_esp_mount"
    fi

    cat > /boot/loader/entries/windows.conf <<'EOF'
    title Windows Boot Manager
    efi /EFI/Microsoft/Boot/bootmgfw.efi
    sort-key z_windows
    EOF
  '';

  system.stateVersion = "24.05";
}
