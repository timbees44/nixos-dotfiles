#!/usr/bin/env bash
set -euo pipefail
pattern='wofi --show drun'
if pgrep -f "$pattern" >/dev/null 2>&1; then
  pkill -f "$pattern"
  exit 0
fi
exec wofi --show drun
