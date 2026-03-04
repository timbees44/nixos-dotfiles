#!/usr/bin/env bash
set -euo pipefail

rfkill unblock wifi >/dev/null 2>&1 || true

if ! command -v nmcli >/dev/null 2>&1; then
  exit 0
fi

nmcli radio wifi on >/dev/null 2>&1 || true

find_wifi_iface() {
  nmcli -t -f DEVICE,TYPE device status \
    | awk -F: '$2 == "wifi" && $1 != "" { print $1; exit }'
}

iface=""
for _ in {1..5}; do
  iface=$(find_wifi_iface)
  if [[ -n "$iface" ]]; then
    break
  fi
  sleep 1
done

if [[ -n "$iface" ]]; then
  nmcli device connect "$iface" >/dev/null 2>&1 || true
fi
