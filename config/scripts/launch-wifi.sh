#!/usr/bin/env bash
set -euo pipefail

APP_ID="org.tim.impala"

rfkill unblock wifi >/dev/null 2>&1 || true

focus_existing() {
  command -v hyprctl >/dev/null 2>&1 || return 1
  command -v jq >/dev/null 2>&1 || return 1

  local address
  local clients
  clients=$(hyprctl clients -j 2>/dev/null) || return 1
  address=$(jq -r --arg app "$APP_ID" '
        .[]
        | select(
            (.class // "") == $app
            or (.initialClass // "") == $app
            or (.appID // "") == $app
          )
        | .address' <<<"$clients" | head -n1)

  if [[ -n "$address" ]]; then
    hyprctl dispatch focuswindow "address:$address" >/dev/null 2>&1 || true
    return 0
  fi

  return 1
}

launch_impala() {
  if command -v wezterm >/dev/null 2>&1; then
    wezterm start --always-new-process --class "$APP_ID" -- bash -lc 'rfkill unblock wifi >/dev/null 2>&1 || true; exec impala' &
  elif command -v foot >/dev/null 2>&1; then
    foot --app-id "$APP_ID" impala &
  else
    impala &
  fi
}

if ! focus_existing; then
  launch_impala
fi
