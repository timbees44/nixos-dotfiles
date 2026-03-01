{ config, pkgs, ... }:
let
  lanInterface = "enp3s0"; # adjust if your NIC name differs
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "server";
    useDHCP = false;
    interfaces.${lanInterface}.ipv4.addresses = [
      { address = "192.168.1.67"; prefixLength = 24; }
      { address = "192.168.1.94"; prefixLength = 24; }
    ];
    defaultGateway = "192.168.1.1";
    nameservers = [ "192.168.1.1" "1.1.1.1" ];
    hosts = {
      "192.168.1.67" = [ "jellyfin.lan" "media.lan" ];
      "192.168.1.94" = [ "immich.lan" "photos.lan" ];
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 8096 8920 2283 ];
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
      ];
      listen-address = [ "192.168.1.67" "192.168.1.94" "127.0.0.1" ];
    };
  };

  services.jellyfin = {
    enable = true;
    openFirewall = false;
    dataDir = "/var/lib/jellyfin";
    cacheDir = "/var/cache/jellyfin";
  };

  services.immich = {
    enable = true;
    host = "192.168.1.94";
    port = 2283;
    mediaLocation = "/var/lib/immich/library";
    openFirewall = false;
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/jellyfin 0750 jellyfin jellyfin - -"
    "d /var/cache/jellyfin 0750 jellyfin jellyfin - -"
    "d /var/lib/immich 0750 immich immich - -"
    "d /var/lib/immich/library 0750 immich immich - -"
  ];

  users.users.tim = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  services.openssh.enable = true;

  time.timeZone = "Europe/London";

  environment.systemPackages = with pkgs; [
    dnsutils
  ];

  system.stateVersion = "24.05";
}
