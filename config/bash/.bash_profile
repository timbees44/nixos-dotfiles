# Source interactive configuration
if [ -f "$HOME/.bashrc" ]; then
  source "$HOME/.bashrc"
fi

# Autostart the compositor from the first TTY when no graphical session is running
if [ -z "$WAYLAND_DISPLAY" ] && [ -z "$DISPLAY" ] && [ "${XDG_VTNR:-}" = "1" ]; then
  if uwsm check may-start; then
    exec uwsm start hyprland.desktop
  fi
fi
