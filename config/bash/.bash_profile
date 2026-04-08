# Source interactive configuration
if [ -f "$HOME/.bashrc" ]; then
  source "$HOME/.bashrc"
fi

# Autostart the compositor from the first TTY when no graphical session is running
if [ -z "$WAYLAND_DISPLAY" ] && [ -z "$DISPLAY" ] && [ "${XDG_VTNR:-}" = "1" ]; then
  case "$(hostname -s 2>/dev/null)" in
    horus)
      export XDG_CURRENT_DESKTOP=dwl
      export XDG_SESSION_DESKTOP=dwl
      export XDG_SESSION_TYPE=wayland
      exec dbus-run-session -- sh -lc 'exec dwl -s "$HOME/.config/dwl/autostart.sh"'
      ;;
    *)
      exec uwsm start -S hyprland-uwsm.desktop
      ;;
  esac
fi
