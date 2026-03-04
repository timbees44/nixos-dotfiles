#!/usr/bin/env bash
set -euo pipefail
rfkill unblock bluetooth >/dev/null 2>&1 || true
if command -v foot >/dev/null 2>&1; then
  foot -e bluetui &
else
  bluetui &
fi
