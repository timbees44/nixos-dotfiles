# Source interactive configuration
if [ -f "$HOME/.bashrc" ]; then
  source "$HOME/.bashrc"
fi

# Autostart Hyprland from the first TTY when no Wayland session is running
if [ -z "$WAYLAND_DISPLAY" ] && [ "${XDG_VTNR:-}" = "1" ]; then
  exec uwsm start -S hyprland-uwsm.desktop
fi
