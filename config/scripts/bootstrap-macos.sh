#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CONFIG_DIR="${REPO_ROOT}/config"

usage() {
  cat <<'EOF'
Usage: bootstrap-macos.sh [--with-ui]

Install core macOS packages with Homebrew and link the shared dotfiles used
across Linux and macOS. By default this only installs the core terminal/editor
tooling. Pass --with-ui to also link optional macOS UI config and set wallpaper.
EOF
}

WITH_UI=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --with-ui)
      WITH_UI=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if ! command -v brew >/dev/null 2>&1; then
  cat <<'EOF' >&2
Homebrew is required but not installed.
Install it first:
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
EOF
  exit 1
fi

link_path() {
  local src="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"
  ln -sfn "$src" "$dest"
}

write_file() {
  local dest="$1"
  shift
  mkdir -p "$(dirname "$dest")"
  cat >"$dest" <<EOF
$*
EOF
}

brew_install_if_missing() {
  local formula
  for formula in "$@"; do
    if ! brew list --formula "$formula" >/dev/null 2>&1; then
      brew install "$formula"
    fi
  done
}

brew_install_cask_if_missing() {
  local cask
  for cask in "$@"; do
    if ! brew list --cask "$cask" >/dev/null 2>&1; then
      brew install --cask "$cask"
    fi
  done
}

CORE_FORMULAE=(
  bash
  bat
  btop
  cmake
  coreutils
  eza
  fd
  fzf
  gawk
  gnupg
  gnu-sed
  gnu-tar
  grep
  jq
  libtool
  make
  neovim
  node
  ripgrep
  starship
  tmux
  tree
  wezterm
  zoxide
)

OPTIONAL_FORMULAE=(
  isync
  msmtp
  mu
)

UI_CASKS=(
  aerospace
  karabiner-elements
  skim
)

echo "Installing core Homebrew packages..."
brew_install_if_missing "${CORE_FORMULAE[@]}"

echo "Installing optional mail packages..."
brew_install_if_missing "${OPTIONAL_FORMULAE[@]}"

if [[ "$WITH_UI" -eq 1 ]]; then
  echo "Installing optional UI casks..."
  brew_install_cask_if_missing "${UI_CASKS[@]}"
fi

echo "Linking shared config..."
mkdir -p "$HOME/.config" "$HOME/.emacs.d" "$HOME/pictures/walls"

link_path "${CONFIG_DIR}/bash/.bashrc" "$HOME/.bashrc"
link_path "${CONFIG_DIR}/bash/.bash_profile" "$HOME/.bash_profile"
link_path "${CONFIG_DIR}/zsh/.zshrc" "$HOME/.zshrc"
link_path "${CONFIG_DIR}/zsh/.zprofile" "$HOME/.zprofile"

link_path "${CONFIG_DIR}/emacs-kick" "$HOME/.config/emacs"
link_path "${CONFIG_DIR}/nvim" "$HOME/.config/nvim"
link_path "${CONFIG_DIR}/starship" "$HOME/.config/starship"
link_path "${CONFIG_DIR}/tmux" "$HOME/.config/tmux"
link_path "${CONFIG_DIR}/wezterm" "$HOME/.config/wezterm"

if [[ "$WITH_UI" -eq 1 ]]; then
  link_path "${CONFIG_DIR}/aerospace" "$HOME/.config/aerospace"
  link_path "${CONFIG_DIR}/karabiner" "$HOME/.config/karabiner"
  link_path "${CONFIG_DIR}/sketchybar" "$HOME/.config/sketchybar"
  link_path "${CONFIG_DIR}/walls/prometheus.png" "$HOME/pictures/walls/prometheus.png"
fi

write_file "$HOME/.emacs" '(load-file (expand-file-name "~/.config/emacs/init.el"))'
write_file "$HOME/.emacs.d/init.el" '(load-file (expand-file-name "~/.config/emacs/init.el"))'

if [[ "$WITH_UI" -eq 1 && -f "$HOME/pictures/walls/prometheus.png" ]]; then
  /usr/bin/osascript <<EOF || true
tell application "System Events"
  tell every desktop
    set picture to POSIX file "$HOME/pictures/walls/prometheus.png"
  end tell
end tell
EOF
fi

echo
echo "Bootstrap complete."
echo "Custom repo scripts are available from: $HOME/projects/nixos-dotfiles/config/scripts"
echo "Open a fresh shell or run: exec zsh"
