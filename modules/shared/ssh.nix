{ lib, ... }:
{
  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = lib.mkDefault true;
      KbdInteractiveAuthentication = false;
    };
  };

  networking.firewall.enable = lib.mkDefault true;
}
