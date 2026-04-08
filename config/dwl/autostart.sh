#!/usr/bin/env sh

set -eu
exec </dev/null

export XDG_CURRENT_DESKTOP=dwl
export XDG_SESSION_DESKTOP=dwl
export XDG_SESSION_TYPE=wayland

dbus-update-activation-environment --systemd \
  DISPLAY \
  WAYLAND_DISPLAY \
  XDG_CURRENT_DESKTOP \
  XDG_SESSION_DESKTOP \
  XDG_SESSION_TYPE \
  DBUS_SESSION_BUS_ADDRESS >/dev/null 2>&1 || true

systemctl --user import-environment \
  DISPLAY \
  WAYLAND_DISPLAY \
  XDG_CURRENT_DESKTOP \
  XDG_SESSION_DESKTOP \
  XDG_SESSION_TYPE \
  DBUS_SESSION_BUS_ADDRESS >/dev/null 2>&1 || true

swaybg -c "#1d2021" &
bg_pid=$!

swayidle -w \
  timeout 900 "$HOME/.config/dwl/lock.sh" \
  before-sleep "$HOME/.config/dwl/lock.sh" &
idle_pid=$!

dwlb \
  -font "JetBrainsMonoNL Nerd Font Mono:size=11" \
  &
bar_pid=$!

"$HOME/.config/dwl/status.sh" | dwlb -status-stdin all &
status_pid=$!

trap 'kill "$bg_pid" "$idle_pid" "$bar_pid" "$status_pid" 2>/dev/null || true' INT TERM EXIT
wait
