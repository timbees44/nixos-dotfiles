{ lib, ... }:
{
  imports = [
    ./common.nix
    ../modules/home/gpg-agent-linux.nix
  ];

  home.activation.ensureLinuxBootstrapDirs = lib.hm.dag.entryBefore [ "dconfSettings" ] ''
    mkdir -p "$HOME/.config/dconf" "$HOME/.config/age" "$HOME/.config/isync" "$HOME/.config/msmtp"
  '';
}
