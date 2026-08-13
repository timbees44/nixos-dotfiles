{ config, lib, ... }:
let
  cfg = config.services.homelab;
  fqdn = subdomain: "${subdomain}.${cfg.domain}";
  proxyBlock = port: extra: ''
    tls internal
    reverse_proxy ${cfg.proxyAddress}:${toString port}${extra}
  '';
  proxyWithBlock = port: lines: proxyBlock port '' {
${lines}
    }
  '';
  simpleProxy = port: { extraConfig = proxyBlock port ""; };
in
{
  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
      virtualHosts = {
        "${fqdn "jellyfin"}" = simpleProxy 8096;
        "${fqdn "audiobookshelf"}" = simpleProxy 13378;
        "${fqdn "calibre"}" = simpleProxy 8083;
        "${fqdn "frigate"}" = simpleProxy 5000;
        "${fqdn "homeassistant"}".extraConfig = proxyWithBlock 8123 ''
          header_up Host {host}
          header_up X-Forwarded-For {remote_host}
          header_up X-Forwarded-Proto {scheme}
        '';
        "${fqdn "immich"}".extraConfig = proxyWithBlock 2283 ''
          header_up X-Forwarded-For {remote_host}
          header_up X-Forwarded-Proto {scheme}
        '';
        "${fqdn "syncthing"}".extraConfig = proxyWithBlock 8384 ''
          header_up Host localhost:8384
          header_up X-Forwarded-Host {host}
        '';
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkBefore [ 80 443 ];
  };
}
