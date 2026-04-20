#!/usr/bin/env bash

AEROSPACE_BIN="$(command -v aerospace || true)"
if [ -z "$AEROSPACE_BIN" ] && [ -x "/opt/homebrew/bin/aerospace" ]; then
  AEROSPACE_BIN="/opt/homebrew/bin/aerospace"
fi
if [ -z "$AEROSPACE_BIN" ] && [ -x "/run/current-system/sw/bin/aerospace" ]; then
  AEROSPACE_BIN="/run/current-system/sw/bin/aerospace"
fi

focused_workspace="${FOCUSED_WORKSPACE:-${INFO:-}}"
if [ -z "$focused_workspace" ]; then
  focused_workspace="$("$AEROSPACE_BIN" list-workspaces --focused 2>/dev/null | head -n 1)"
fi

if [ "$1" = "$focused_workspace" ]; then
    sketchybar --set "$NAME" \
      label.color=0xffebdbb2 \
      label.font="JetBrainsMono Nerd Font:Bold:14.0"
else
    sketchybar --set "$NAME" \
      label.color=0x77ebdbb2 \
      label.font="JetBrainsMono Nerd Font:Regular:14.0"
fi
