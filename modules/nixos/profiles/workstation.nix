{ pkgs, primaryUser, ... }:
{
  networking.networkmanager = {
    enable = true;
    wifi = {
      powersave = false;
      backend = "wpa_supplicant";
    };
  };

  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };
  services.udisks2.enable = true;
  services.gvfs.enable = true;

  security.polkit.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  users.users.${primaryUser} = {
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
    gparted
    pkg-config
    libtool
    unzip
    gnutar
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
}
