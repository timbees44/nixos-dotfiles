{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager = {
    enable = true;
    wifi = {
      powersave = false;
      backend = "wpa_supplicant";
    };
  };

  time.timeZone = "Europe/London";

  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.displayManager.defaultSession = "hyprland-uwsm";

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  users.users.tim = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    cmake
    gnumake
    gcc
    pkg-config
    libtool
    unzip
    gnutar
  ];

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };
  services.power-profiles-daemon.enable = true;

  # Use a system-sleep hook so Wi-Fi always restarts on resume even if sleep.target ordering changes.
  environment.etc."systemd/system-sleep/99-wifi-resume" = {
    mode = "0755";
    source = pkgs.writeShellScript "wifi-resume-hook" ''
      set -euo pipefail
      rfkill_cmd=${pkgs.util-linux}/bin/rfkill
      nmcli_cmd=${pkgs.networkmanager}/bin/nmcli
      sleep_cmd=${pkgs.coreutils}/bin/sleep
      awk_cmd=${pkgs.gawk}/bin/awk
      grep_cmd=${pkgs.gnugrep}/bin/grep
      logger_cmd=${pkgs.util-linux}/bin/logger
      systemctl_cmd=${pkgs.systemd}/bin/systemctl

      log() {
        "$logger_cmd" -t wifi-resume -- "$@"
      }

      find_wifi_iface() {
        "$nmcli_cmd" -t -f DEVICE,TYPE device status \
          | "$awk_cmd" -F: '$2 == "wifi" && $1 != "" { print $1; exit }'
      }

      wifi_connected() {
        local iface="$1"
        "$nmcli_cmd" -t -f GENERAL.STATE device show "$iface" 2>/dev/null \
          | "$grep_cmd" -q ":100 (connected)"
      }

      attempt_connect() {
        local iface="$1"
        "$nmcli_cmd" device connect "$iface" >/dev/null 2>&1
      }

      ensure_radio() {
        "$rfkill_cmd" unblock wifi >/dev/null 2>&1 || true
        "$nmcli_cmd" radio wifi on >/dev/null 2>&1 || true
      }

      toggle_radio() {
        "$nmcli_cmd" radio wifi off >/dev/null 2>&1 || true
        "$sleep_cmd" 1
        "$nmcli_cmd" radio wifi on >/dev/null 2>&1 || true
      }

      resume_wifi() {
        local target="$1"
        log "Resume event detected for $target"
        ensure_radio
        "$systemctl_cmd" try-restart NetworkManager.service >/dev/null 2>&1 || log "NetworkManager restart failed"

        attempt=1
        max_attempts=6
        while [ "$attempt" -le "$max_attempts" ]; do
          iface=$(find_wifi_iface || true)
          if [ -z "$iface" ]; then
            log "No Wi-Fi interface detected (attempt ''${attempt}/''${max_attempts})"
          elif wifi_connected "$iface"; then
            log "Wi-Fi already connected on $iface"
            return 0
          elif attempt_connect "$iface"; then
            log "Wi-Fi connected on $iface"
            return 0
          else
            log "Failed to connect on $iface (attempt ''${attempt}/''${max_attempts}), toggling radio"
            toggle_radio
          fi
          "$sleep_cmd" 2
          attempt=$((attempt + 1))
        done

        log "Wi-Fi resume retries exhausted after ''${max_attempts} attempts"
      }

      case "$1/$2" in
        post/*)
          resume_wifi "$2" &
          ;;
      esac
    '';
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  security.pam.services.swaylock = {};

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.05";

}
