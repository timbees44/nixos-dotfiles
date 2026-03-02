{ lib, ... }:
{
  age.identityPaths = lib.mkDefault [ "/etc/age/keys.txt" ];
}
