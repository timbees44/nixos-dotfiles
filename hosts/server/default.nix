{ config, pkgs, lib, ... }:
let
  lanInterface = "enp58s0u1u2"; # primary ethernet NIC
  frigateSecretFile = ../../secrets/frigate-reolink-env.age;
  lidBacklightScript = pkgs.writeShellScript "lid-backlight.sh" ''
    state=$(cat /proc/acpi/button/lid/*/state)
    if echo "$state" | grep -q closed; then
      for bl in /sys/class/backlight/*; do
        echo 4 > "$bl/bl_power" 2>/dev/null
      done
    else
      for bl in /sys/class/backlight/*; do
        echo 0 > "$bl/bl_power" 2>/dev/null
        brightness=$(cat "$bl/max_brightness" 2>/dev/null)
        [ -n "$brightness" ] && echo "$brightness" > "$bl/brightness" 2>/dev/null
      done
    fi
  '';
  lidBacklightAction = builtins.toString lidBacklightScript;
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  age.secrets = lib.optionalAttrs (builtins.pathExists frigateSecretFile) {
    frigate-reolink-env = {
      file = frigateSecretFile;
      path = "/run/agenix/frigate-reolink-env";
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };

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

  # Tailscale node service. Initial auth can be done once with `tailscale up`
  # or later wired to an auth key file managed by agenix.
  services.tailscale.enable = true;

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
      action = lidBacklightAction;
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
        "syncthing.lan"
        "audiobookshelf.lan"
        "calibre.lan"
        "frigate.lan"
        "homeassistant.lan"
        "immich.lan"
        "photos.lan"
      ];
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 53 80 443
        8096 # jellyfin
        8384 # syncthing UI
        13378 # audiobookshelf
        8083 # calibre
        2283 # immich
        5000 # frigate
        8123 # ha
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
        "/frigate.lan/192.168.1.67"
        "/homeassistant.lan/192.168.1.67"
        "/immich.lan/192.168.1.67"
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
