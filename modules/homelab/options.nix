{ lib, primaryUser, ... }:
{
  options.services.homelab = {
    enable = lib.mkEnableOption "the media and storage homelab stack";

    user = lib.mkOption {
      type = lib.types.str;
      default = primaryUser;
      description = "User that owns the media data and services.";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "lan";
      description = "Domain suffix for reverse proxy hostnames.";
    };

    mediaDir = lib.mkOption {
      type = lib.types.str;
      default = "/srv/media";
      description = "Base directory holding media libraries.";
    };

    timezone = lib.mkOption {
      type = lib.types.str;
      default = "UTC";
      description = "Timezone used by containers and services that need it.";
    };

    serviceAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address services bind to.";
    };

    proxyAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address Caddy uses when proxying to services.";
    };
  };
}
