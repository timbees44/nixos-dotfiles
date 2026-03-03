{ config, pkgs, ... }:
let
  lanInterface = "enp58s0u1u2"; # primary ethernet NIC
  lidBacklightScript = pkgs.writeShellScript "lid-backlight.sh" ''
    state=$(cat /proc/acpi/button/lid/*/state)
    if echo "$state" | grep -q closed; then
      for bl in /sys/class/backlight/*; do
        echo 4 > "$bl/bl_power" 2>/dev/null
        echo 0 > "$bl/brightness" 2>/dev/null
      done
    else
      for bl in /sys/class/backlight/*; do
        echo 0 > "$bl/bl_power" 2>/dev/null
      done
    fi
  '';
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

  services.openssh.settings = {
    PermitRootLogin = "no";
    PasswordAuthentication = true;
    KbdInteractiveAuthentication = false;
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ pkgs.vulkan-validation-layers ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = false;
    powerManagement.enable = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.production;
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  services.acpid = {
    enable = true;
    handlers.lid = {
      event = "button/lid.*";
      command = lidBacklightScript;
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "server";
    useNetworkd = true;
    networkmanager.enable = false;
    interfaces.${lanInterface} = {
      useDHCP = false;
      ipv4.addresses = [
        { address = "192.168.1.67"; prefixLength = 24; }
      ];
    };
    defaultGateway = {
      address = "192.168.1.1";
      interface = lanInterface;
    };
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
        "immich.lan"
        "photos.lan"
      ];
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

  services.resolved.enable = false;

  services.dnsmasq = {
    enable = true;
    settings = {
      server = [ "1.1.1.1" "1.0.0.1" ];
      address = [
        "/jellyfin.lan/192.168.1.67"
        "/immich.lan/192.168.1.67"
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
      listen-address = [ "192.168.1.67" "127.0.0.1" ];
    };
  };

  users.users.tim = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys = {
      keyFiles = [
        ../../config/ssh/server-ed25519.pub
      ];
    };
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
