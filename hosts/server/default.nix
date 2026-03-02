{ config, pkgs, ... }:
let
  lanInterface = "wlp59s0"; # adjust to your wireless NIC
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  services.homelab = {
    enable = true;
    user = "tim";
    domain = "lan";
    mediaDir = "/srv/media";
    timezone = "Europe/London";
    serviceAddress = "0.0.0.0";
    proxyAddress = "127.0.0.1";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "server";
    useDHCP = false;
    networkmanager.enable = true;
    interfaces.${lanInterface}.ipv4.addresses = [
      { address = "192.168.1.67"; prefixLength = 24; }
      { address = "192.168.1.94"; prefixLength = 24; }
    ];
    defaultGateway = "192.168.1.1";
    nameservers = [ "192.168.1.1" "1.1.1.1" ];
    hosts = {
      "192.168.1.67" = [
        "jellyfin.lan"
        "radarr.lan"
        "sonarr.lan"
        "lidarr.lan"
        "bazarr.lan"
        "prowlarr.lan"
        "sabnzbd.lan"
        "syncthing.lan"
        "audiobookshelf.lan"
        "calibre.lan"
      ];
      "192.168.1.94" = [ "immich.lan" "photos.lan" ];
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 53 80 443
        8096 # jellyfin
        7878 # radarr
        8989 # sonarr
        8686 # lidarr
        6767 # bazarr
        9696 # prowlarr
        8080 # sabnzbd
        8384 # syncthing UI
        13378 # audiobookshelf
        8083 # calibre
        2283 # immich
      ];
      allowedUDPPorts = [ 53 ];
    };
  };

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = true;
    settings = {
      server = [ "1.1.1.1" "1.0.0.1" ];
      address = [
        "/jellyfin.lan/192.168.1.67"
        "/immich.lan/192.168.1.94"
        "/radarr.lan/192.168.1.67"
        "/sonarr.lan/192.168.1.67"
        "/lidarr.lan/192.168.1.67"
        "/bazarr.lan/192.168.1.67"
        "/prowlarr.lan/192.168.1.67"
        "/sabnzbd.lan/192.168.1.67"
        "/syncthing.lan/192.168.1.67"
        "/audiobookshelf.lan/192.168.1.67"
        "/calibre.lan/192.168.1.67"
      ];
      listen-address = [ "192.168.1.67" "192.168.1.94" "127.0.0.1" ];
    };
  };

  users.users.tim = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  time.timeZone = "Europe/London";

  environment.systemPackages = with pkgs; [
    dnsutils
    git
    networkmanager
    vim
  ];

  system.stateVersion = "24.05";
}
