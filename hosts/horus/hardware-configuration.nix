# Replace this file with `nixos-generate-config` output from horus before the
# first real install or rebuild on that machine.
{ lib, ... }:

{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
