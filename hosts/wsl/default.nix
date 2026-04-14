{ lib, pkgs, ... }:
{
  wsl = {
    enable = true;
    defaultUser = "tim";
    startMenuLaunchers = true;
  };

  networking.hostName = "wsl";
  networking.firewall.enable = lib.mkForce false;

  services.openssh.enable = lib.mkForce false;

  users.users.tim = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    git
    wget
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.05";
}
