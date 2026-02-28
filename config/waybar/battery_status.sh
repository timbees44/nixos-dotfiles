#!/usr/bin/env bash
set -euo pipefail

# Find the first battery exposed by the kernel
battery_dir=""
for candidate in /sys/class/power_supply/BAT*; do
    if [ -d "$candidate" ]; then
        battery_dir="$candidate"
        break
    fi
done

if [ -z "$battery_dir" ]; then
    # No battery detected; Waybar's exec-if should prevent us from running,
    # but bail out just in case.
    exit 0
fi

capacity_file="$battery_dir/capacity"
status_file="$battery_dir/status"

if [ ! -r "$capacity_file" ]; then
    exit 0
fi

capacity=$(cat "$capacity_file" 2>/dev/null || echo "0")
status=$(cat "$status_file" 2>/dev/null || echo "Unknown")

suffix=""
if [ "$status" = "Charging" ]; then
    suffix=" "
fi

printf '%s%%%s\n' "$capacity" "$suffix"
