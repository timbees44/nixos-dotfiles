#!/usr/bin/env bash
set -euo pipefail
rfkill unblock wifi >/dev/null 2>&1 || true

if command -v wezterm >/dev/null 2>&1; then
  wezterm start --always-new-process -- bash -lc 'impala || { echo "impala exited"; read -r; }' &
elif command -v foot >/dev/null 2>&1; then
  foot -e bash -lc 'impala || { echo "impala exited"; read -r; }' &
else
  foot -e bash -lc 'impala || { echo "impala exited"; read -r; }' &
fi
