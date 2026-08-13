{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.homelab;
  hasFrigateSecret = config.age.secrets ? frigate-reolink-env;
  calibreConfigDir = "/var/lib/calibre-web-automated";
  ensureDir = path: owner: group: mode: "d '${path}' ${mode} ${owner} ${group} - -";
  mediaSubdirRule = name: ensureDir "${cfg.mediaDir}/${name}" cfg.user "media" "0755";
  dnsAddr = "${cfg.serviceAddress}";
in
{
  imports = [
    ./options.nix
    ./proxy.nix
  ];

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
      host = dnsAddr;
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

    # *arr stack disabled by default; enable per host if needed

    services.audiobookshelf = {
      enable = true;
      host = dnsAddr;
      port = 13378;
      openFirewall = false;
    };

    services.mosquitto = {
      enable = true;
      listeners = [
        {
          address = "127.0.0.1";
          port = 1883;
          acl = [ "pattern readwrite #" ];
          omitPasswordAuth = true;
          settings.allow_anonymous = true;
        }
      ];
    };

    services.home-assistant = {
      enable = true;
      configDir = "/var/lib/hass";
      extraComponents = [ "ffmpeg" "mqtt" "stream" ];
      extraPackages = python3Packages: [
        python3Packages.reolink-aio
        python3Packages.universal-silabs-flasher
        python3Packages.ha-silabs-firmware-client
        python3Packages.zha
      ];
      customComponents = with pkgs.home-assistant-custom-components; [ frigate ];
      config = {
        default_config = { };
        automation = "!include automations.yaml";
        script = "!include scripts.yaml";
        scene = "!include scenes.yaml";
        homeassistant = {
          name = "Home Server";
          time_zone = cfg.timezone;
          unit_system = "metric";
          country = "GB";
        };
        http = {
          server_port = 8123;
          use_x_forwarded_for = true;
          trusted_proxies = [ "127.0.0.1" "::1" cfg.proxyAddress ];
          ip_ban_enabled = true;
          login_attempts_threshold = 5;
        };
        ffmpeg = { };
      };
    };

    systemd.services.home-assistant.serviceConfig.SupplementaryGroups = [ "video" "render" "dialout" ];

    environment.etc = {
      "frigate/config.yaml".text = ''
        mqtt:
          enabled: true
          host: 127.0.0.1
          port: 1883

        birdseye:
          enabled: true

        ffmpeg:
          hwaccel_args: preset-vaapi
          output_args:
            record: preset-record-generic-audio-aac

        detectors:
          ov:
            type: openvino
            device: GPU

        model:
          width: 300
          height: 300
          input_tensor: nhwc
          input_pixel_format: bgr
          path: /openvino-model/ssdlite_mobilenet_v2.xml
          labelmap_path: /openvino-model/coco_91cl_bkgr.txt

        record:
          enabled: true
          continuous:
            days: 7
          motion:
            days: 7
          alerts:
            pre_capture: 2
            post_capture: 3
            retain:
              days: 14
              mode: motion
          detections:
            pre_capture: 2
            post_capture: 3
            retain:
              days: 14
              mode: motion

        review:
          alerts:
            labels:
              - person
            required_zones:
              - people_drive
              - people_front
          detections:
            labels:
              - person
            required_zones:
              - people_drive
              - people_front

        snapshots:
          enabled: true
          required_zones:
            - people_drive
            - people_front
          retain:
            default: 30

        go2rtc:
          streams:
            reolink_main:
              - rtsp://{FRIGATE_REOLINK_USER}:{FRIGATE_REOLINK_PASSWORD}@{FRIGATE_REOLINK_HOST}:554/h264Preview_01_main
            reolink_sub:
              - rtsp://{FRIGATE_REOLINK_USER}:{FRIGATE_REOLINK_PASSWORD}@{FRIGATE_REOLINK_HOST}:554/h264Preview_01_sub

        cameras:
          reolink_poe:
            ffmpeg:
              inputs:
                - path: rtsp://127.0.0.1:8554/reolink_sub
                  input_args: preset-rtsp-restream
                  roles:
                    - detect
                - path: rtsp://127.0.0.1:8554/reolink_main
                  input_args: preset-rtsp-restream
                  roles:
                    - record
            detect:
              enabled: true
              width: 1280
              height: 720
              fps: 5
            objects:
              track:
                - person
            zones:
              people_drive:
                coordinates: 0,0.342,0.383,0.491,0.505,1,0.001,0.999
                loitering_time: 0
                objects:
                  - person
                friendly_name: People Drive
              people_front:
                coordinates: 0.869,0.36,0.998,0.534,1,0.998,0.505,1,0.384,0.497
                loitering_time: 0
                objects:
                  - person
                friendly_name: People Front
      '';
      "frigate/frigate.env.example".text = ''
        FRIGATE_REOLINK_HOST=192.168.1.50
        FRIGATE_REOLINK_USER=admin
        FRIGATE_REOLINK_PASSWORD=replace-me
      '';
    };

    systemd.tmpfiles.rules = [
      "f /var/lib/hass/automations.yaml 0600 hass hass -"
      "f /var/lib/hass/scripts.yaml 0600 hass hass -"
      "f /var/lib/hass/scenes.yaml 0600 hass hass -"
      (ensureDir cfg.mediaDir cfg.user "media" "0755")
      (mediaSubdirRule "movies")
      (mediaSubdirRule "tvshows")
      (mediaSubdirRule "music")
      (mediaSubdirRule "books")
      (mediaSubdirRule "books-ingest")
      (mediaSubdirRule "audiobooks")
      (mediaSubdirRule "photos")
      (ensureDir "${cfg.mediaDir}/security" cfg.user "media" "0755")
      (ensureDir "${cfg.mediaDir}/security/frigate" cfg.user "media" "0755")
      (ensureDir "${cfg.mediaDir}/security/frigate/config" "root" "root" "0755")
      (ensureDir calibreConfigDir cfg.user "media" "0755")
      (ensureDir "${calibreConfigDir}/config" cfg.user "media" "0755")
      (ensureDir "/var/lib/immich" "immich" "immich" "0750")
      (ensureDir "/var/lib/immich/library" "immich" "immich" "0750")
      (ensureDir "/var/lib/immich/upload" "immich" "immich" "0750")
      (ensureDir "/var/cache/frigate" "root" "root" "0755")
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
        "${cfg.mediaDir}/books:/calibre-library"
        "${cfg.mediaDir}/books-ingest:/cwa-book-ingest"
        "${calibreConfigDir}/config:/config"
      ];
      environment = {
        PUID = "1000";
        PGID = "100";
        TZ = cfg.timezone;
        CALIBRE_LIBRARY_PATH = "/calibre-library";
        METADATA_UPDATE = "true";
      };
    };

    virtualisation.oci-containers.containers.frigate = {
      image = "ghcr.io/blakeblackshear/frigate:stable";
      autoStart = hasFrigateSecret;
      ports = [ "${cfg.proxyAddress}:5000:5000" ];
      volumes = [
        "/etc/localtime:/etc/localtime:ro"
        "${cfg.mediaDir}/security/frigate/config:/config"
        "${cfg.mediaDir}/security/frigate:/media/frigate"
        "/var/cache/frigate:/tmp/cache"
      ];
      environment = {
        LIBVA_DRIVER_NAME = "iHD";
        FRIGATE_RTSP_PASSWORD = "";
      };
      environmentFiles = optionals hasFrigateSecret [
        config.age.secrets.frigate-reolink-env.path
      ];
      extraOptions = [
        "--device=/dev/dri:/dev/dri"
        "--shm-size=256m"
      ];
    };

    systemd.services.podman-frigate.preStart = ''
      install -d -m 0755 ${cfg.mediaDir}/security/frigate/config
      install -m 0644 /etc/frigate/config.yaml ${cfg.mediaDir}/security/frigate/config/config.yaml
    '';

  };
}
