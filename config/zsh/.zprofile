# Load the multi-user Nix install environment when present.
if [ -r /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

add_path() {
  if [ -d "$1" ]; then
    export PATH="$1:$PATH"
  fi
}

export BAT_THEME=ansi

add_path "$HOME/.opencode/bin"
add_path "$HOME/projects/nixos-dotfiles/config/scripts"
add_path "$HOME/.cargo/bin"
add_path "$HOME/.local/bin"
add_path "$HOME/.emacs.d/bin"
add_path "$HOME/.config/emacs/bin"
add_path "$HOME/.nix-profile/bin"
add_path "/etc/profiles/per-user/$USER/bin"
add_path "/nix/var/nix/profiles/system/sw/bin"
add_path "/run/current-system/sw/bin"
add_path "/opt/homebrew/bin"
add_path "/usr/local/bin"

# Import Home Manager session variables when available.
for hm_vars in \
  "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" \
  "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
do
  if [ -r "$hm_vars" ]; then
    . "$hm_vars"
  fi
done

# Autostart the compositor from the first Linux TTY when no graphical session is running.
if [ "$(uname -s)" = "Linux" ] && [ -z "$WAYLAND_DISPLAY" ] && [ -z "$DISPLAY" ] && [ "${XDG_VTNR:-}" = "1" ]; then
  if command -v uwsm >/dev/null 2>&1 && uwsm check may-start; then
    exec uwsm start hyprland.desktop
  fi
fi

if [[ -o interactive ]] && [ -r "$HOME/.zshrc" ]; then
  . "$HOME/.zshrc"
fi
