#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CONFIG_DIR="${REPO_ROOT}/config"

usage() {
  cat <<EOF
Usage: bootstrap-macos.sh [options]

Install core macOS packages with Homebrew, link the shared dotfiles, and
optionally materialize local mail secrets and refresh the GPG agent.

Options:
  --with-ui                 Also link optional macOS UI config and wallpaper.
  --skip-mail-secrets       Skip decrypting mail secrets during bootstrap.
  --mail-secrets-only       Only decrypt mail secrets into local runtime paths.
  --refresh-gpg-agent       Refresh the local GPG agent after the main action.
  --refresh-gpg-agent-only  Only refresh the local GPG agent.
  -h, --help                Show this help text.

Environment overrides:
  AGE_KEY_FILE=/path/to/keys.txt
EOF
}

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

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

require_file() {
  if [[ ! -f "$1" ]]; then
    echo "Missing required file: $1" >&2
    exit 1
  fi
}

ensure_writable_dir() {
  local dir="$1"

  mkdir -p "$dir"

  if [[ ! -d "$dir" ]]; then
    echo "Expected a directory but found something else: $dir" >&2
    exit 1
  fi

  if [[ ! -w "$dir" ]]; then
    cat >&2 <<EOF
Directory is not writable: $dir
If this was created by root previously, fix it with:
  sudo chown -R "$(id -un):$(id -gn)" "$dir"
EOF
    exit 1
  fi
}

decrypt_secret() {
  local encrypted_file="$1"
  local output_file="$2"
  local tmp_file

  tmp_file="$(mktemp "${output_file}.tmp.XXXXXX")"

  if ! age --decrypt -i "$AGE_KEY_FILE" "$encrypted_file" > "$tmp_file"; then
    rm -f "$tmp_file"
    echo "Failed to decrypt: $encrypted_file" >&2
    exit 1
  fi

  chmod 600 "$tmp_file"
  mv "$tmp_file" "$output_file"
}

decrypt_mail_secrets() {
  require_cmd age
  require_file "$AGE_KEY_FILE"
  require_file "$ISYNC_SECRET"
  require_file "$MSMTP_SECRET"

  umask 077
  ensure_writable_dir "$ISYNC_DIR"
  ensure_writable_dir "$MSMTP_DIR"

  decrypt_secret "$ISYNC_SECRET" "$ISYNC_CONFIG"
  decrypt_secret "$MSMTP_SECRET" "$MSMTP_CONFIG"

  echo "Mail secrets wrote:"
  echo "  $ISYNC_CONFIG"
  echo "  $MSMTP_CONFIG"
}

maybe_decrypt_mail_secrets() {
  if [[ -f "$AGE_KEY_FILE" ]]; then
    echo "Decrypting local mail secrets..."
    decrypt_mail_secrets
  else
    echo "Skipping mail secrets: no age key at $AGE_KEY_FILE"
  fi
}

refresh_gpg_agent() {
  require_cmd gpgconf
  require_cmd gpg-connect-agent
  require_cmd ssh-add

  gpgconf --kill gpg-agent
  gpg-connect-agent updatestartuptty /bye >/dev/null
  export SSH_AUTH_SOCK
  SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  echo "SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
  ssh-add -L
}

ensure_homebrew() {
  if ! command -v brew >/dev/null 2>&1; then
    cat <<'EOF' >&2
Homebrew is required but not installed.
Install it first:
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
EOF
    exit 1
  fi
}

CORE_FORMULAE=(
  bat
  btop
  cmake
  codex
  codex-acp
  coreutils
  direnv
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
  age
  isync
  msmtp
  mu
)

UI_CASKS=(
  aerospace
  karabiner-elements
  skim
)

AGE_KEY_FILE="${AGE_KEY_FILE:-${HOME}/.config/age/keys.txt}"
ISYNC_DIR="${HOME}/.config/isync"
MSMTP_DIR="${HOME}/.config/msmtp"
ISYNC_CONFIG="${ISYNC_DIR}/mbsyncrc"
MSMTP_CONFIG="${MSMTP_DIR}/config"
ISYNC_SECRET="${REPO_ROOT}/secrets/mbsyncrc.age"
MSMTP_SECRET="${REPO_ROOT}/secrets/msmtp-config.age"

WITH_UI=0
SKIP_MAIL_SECRETS=0
MAIL_SECRETS_ONLY=0
REFRESH_GPG_AGENT=0
REFRESH_GPG_AGENT_ONLY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --with-ui)
      WITH_UI=1
      shift
      ;;
    --skip-mail-secrets)
      SKIP_MAIL_SECRETS=1
      shift
      ;;
    --mail-secrets-only)
      MAIL_SECRETS_ONLY=1
      shift
      ;;
    --refresh-gpg-agent)
      REFRESH_GPG_AGENT=1
      shift
      ;;
    --refresh-gpg-agent-only)
      REFRESH_GPG_AGENT_ONLY=1
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

if [[ "$MAIL_SECRETS_ONLY" -eq 1 && "$REFRESH_GPG_AGENT_ONLY" -eq 1 ]]; then
  echo "Choose either --mail-secrets-only or --refresh-gpg-agent-only, not both." >&2
  exit 1
fi

run_bootstrap() {
  ensure_homebrew

  echo "Installing core Homebrew packages..."
  brew_install_if_missing "${CORE_FORMULAE[@]}"

  echo "Installing optional mail packages..."
  brew_install_if_missing "${OPTIONAL_FORMULAE[@]}"

  if [[ "$WITH_UI" -eq 1 ]]; then
    echo "Installing optional UI casks..."
    brew_install_cask_if_missing "${UI_CASKS[@]}"
  fi

  echo "Linking shared config..."
  mkdir -p \
    "$HOME/.config" \
    "$HOME/.config/isync" \
    "$HOME/.config/msmtp" \
    "$HOME/.emacs.d" \
    "$HOME/.mail" \
    "$HOME/pictures/walls"

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

  if [[ "$SKIP_MAIL_SECRETS" -eq 0 ]]; then
    maybe_decrypt_mail_secrets
  fi

  echo
  echo "Bootstrap complete."
  echo "Repo scripts live in: $SCRIPT_DIR"
  echo "Open a fresh shell or run: exec zsh"
}

if [[ "$REFRESH_GPG_AGENT_ONLY" -eq 1 ]]; then
  refresh_gpg_agent
  exit 0
fi

if [[ "$MAIL_SECRETS_ONLY" -eq 1 ]]; then
  decrypt_mail_secrets
else
  run_bootstrap
fi

if [[ "$REFRESH_GPG_AGENT" -eq 1 ]]; then
  refresh_gpg_agent
fi
