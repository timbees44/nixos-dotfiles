{ config, lib, ... }:
{
  imports = [
    ./locale.nix
    ./nix.nix
    ./ssh.nix
    ./secrets.nix
  ];

  # Provide a sane default timezone/locale for hosts that do not override it yet.
  time.timeZone = lib.mkDefault "Europe/London";
  i18n.defaultLocale = lib.mkDefault "en_GB.UTF-8";
}
