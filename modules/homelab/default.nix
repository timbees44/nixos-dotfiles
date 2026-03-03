{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.homelab;
  fqdn = sub: "${sub}.${cfg.domain}";
  proxyBlock = port: extra: ''
    tls internal
    reverse_proxy ${cfg.proxyAddress}:${toString port}${extra}
  '';
  proxyWithBlock = port: lines: proxyBlock port '' {
${lines}
    }
  '';
  calibreConfigDir = "/var/lib/calibre-web-automated";
  ensureDir = path: owner: group: mode: "d '${path}' ${mode} ${owner} ${group} - -";
  mediaSubdirRule = name: ensureDir "${cfg.mediaDir}/${name}" cfg.user "media" "0755";
  simpleProxy = port: { extraConfig = proxyBlock port ""; };
  caddyVirtualHosts = {
    "${fqdn "jellyfin"}" = simpleProxy 8096;
    "${fqdn "radarr"}" = simpleProxy 7878;
    "${fqdn "sonarr"}" = simpleProxy 8989;
    "${fqdn "lidarr"}" = simpleProxy 8686;
    "${fqdn "bazarr"}" = simpleProxy 6767;
    "${fqdn "prowlarr"}" = simpleProxy 9696;
    "${fqdn "sabnzbd"}" = simpleProxy 8080;
    "${fqdn "audiobookshelf"}" = simpleProxy 13378;
    "${fqdn "calibre"}" = simpleProxy 8083;
    "${fqdn "immich"}" = {
      extraConfig = proxyWithBlock 2283 ''
      header_up X-Forwarded-For {remote_host}
      header_up X-Forwarded-Proto {scheme}
    '';
    };
    "${fqdn "syncthing"}" = {
      extraConfig = proxyWithBlock 8384 ''
      header_up Host localhost:8384
      header_up X-Forwarded-Host {host}
    '';
    };
  };
in {
  options.services.homelab = {
    enable = mkEnableOption "Enable the media + storage homelab stack";

    user = mkOption {
      type = types.str;
      default = "tim";
      description = "User that owns the media data and services.";
    };

    domain = mkOption {
      type = types.str;
      default = "lan";
      description = "Domain suffix for reverse proxy hostnames (e.g. jellyfin.<domain>).";
    };

    mediaDir = mkOption {
      type = types.str;
      default = "/srv/media";
      description = "Base directory holding media libraries.";
    };

    timezone = mkOption {
      type = types.str;
      default = "UTC";
      description = "Timezone used by containers and services that need it.";
    };

    serviceAddress = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Address services bind to (set to 0.0.0.0 for LAN access).";
    };

    proxyAddress = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Address Caddy should use when proxying to services.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.hasPrefix "/" cfg.mediaDir;
        message = "services.homelab.mediaDir must be an absolute path";
      }
    ];

    users.groups.media = { };

    users.users.${cfg.user}.extraGroups = mkAfter [ "media" "podman" "video" "render" ];

    services.jellyfin = {
      enable = true;
      openFirewall = false;
      dataDir = lib.mkDefault "${cfg.mediaDir}/jellyfin";
      cacheDir = lib.mkDefault "/var/cache/jellyfin";
    };

    systemd.services.jellyfin.serviceConfig.SupplementaryGroups = [ "video" "render" ];

    services.immich = {
      enable = true;
      host = cfg.serviceAddress;
      port = 2283;
      openFirewall = false;
      mediaLocation = "${cfg.mediaDir}/photos";
    };

    services.syncthing = {
      enable = true;
      user = cfg.user;
      dataDir = "/home/${cfg.user}/syncthing";
      configDir = "/home/${cfg.user}/.config/syncthing";
      openDefaultPorts = false;
      guiAddress = "${cfg.serviceAddress}:8384";
      overrideDevices = true;
      overrideFolders = true;
    };

    services.radarr.enable = true;
    services.radarr.openFirewall = false;
    services.sonarr.enable = true;
    services.sonarr.openFirewall = false;
    services.lidarr.enable = true;
    services.lidarr.openFirewall = false;
    services.bazarr.enable = true;
    services.bazarr.openFirewall = false;
    services.prowlarr.enable = true;
    services.prowlarr.openFirewall = false;
    services.sabnzbd.enable = true;
    services.sabnzbd.openFirewall = false;

    services.audiobookshelf = {
      enable = true;
      host = cfg.serviceAddress;
      port = 13378;
      openFirewall = false;
    };

    services.caddy = {
      enable = true;
      virtualHosts = caddyVirtualHosts;
    };

    systemd.tmpfiles.rules = [
      (ensureDir cfg.mediaDir cfg.user "media" "0755")
      (mediaSubdirRule "movies")
      (mediaSubdirRule "tvshows")
      (mediaSubdirRule "music")
      (mediaSubdirRule "books")
      (mediaSubdirRule "audiobooks")
      (mediaSubdirRule "photos")
      (ensureDir calibreConfigDir cfg.user "media" "0755")
      (ensureDir "${calibreConfigDir}/config" cfg.user "media" "0755")
      (ensureDir "/var/lib/immich" "immich" "immich" "0750")
      (ensureDir "/var/lib/immich/library" "immich" "immich" "0750")
      (ensureDir "/var/lib/immich/upload" "immich" "immich" "0750")
    ];

    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = false;
    };

    virtualisation.oci-containers.containers.calibre-web-automated = {
      image = "crocodilestick/calibre-web-automated:latest";
      autoStart = true;
      ports = [ "${cfg.serviceAddress}:8083:8083" ];
      volumes = [
        "${cfg.mediaDir}/books:/books"
        "${calibreConfigDir}/config:/config"
      ];
      environment = {
        PUID = "1000";
        PGID = "100";
        TZ = cfg.timezone;
        CALIBRE_LIBRARY_PATH = "/books";
        METADATA_UPDATE = "true";
      };
    };

    networking.firewall.allowedTCPPorts = mkBefore [ 80 443 ];
  };
}
