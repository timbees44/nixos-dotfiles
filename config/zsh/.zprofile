# Load the multi-user Nix install environment when present.
if [ -r /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

add_path() {
  if [ -d "$1" ]; then
    export PATH="$1:$PATH"
  fi
}

add_path "$HOME/.cargo/bin"
add_path "$HOME/.local/bin"
add_path "$HOME/.emacs.d/bin"
add_path "$HOME/.config/emacs/bin"
add_path "$HOME/.nix-profile/bin"
add_path "/etc/profiles/per-user/$USER/bin"
add_path "/run/current-system/sw/bin"

# Import Home Manager session variables when the profile is available.
for hm_vars in \
  "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" \
  "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
do
  if [ -r "$hm_vars" ]; then
    . "$hm_vars"
  fi
done

if [[ -o interactive ]] && [ -r "$HOME/.zshrc" ]; then
  . "$HOME/.zshrc"
fi
