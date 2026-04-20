if [ -n "${TIM_ZSHRC_LOADED:-}" ]; then
  return
fi
export TIM_ZSHRC_LOADED=1

# starship
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
# starship config
export STARSHIP_CONFIG=~/.config/starship/starship.toml

# Key stuff
if command -v gpgconf >/dev/null 2>&1; then
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
fi

# Enable colors for ls and related commands
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagacad

if [[ -f "/opt/homebrew/bin/brew" ]]; then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' completer _complete
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'
autoload -Uz compinit
# zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
compinit

# Misc Exports
export EDITOR='vi'

# Aliases
alias vi="nvim"
alias vim="nvim"
alias ll="ls -l"
alias sb="cd ~/Documents/second_brain/"
alias pr="cd ~/projects/"
alias dot="cd ~/.dotfiles/"
alias htb="cd ~/projects/htb/"

unalias drs 2>/dev/null
drs() {
  local drb
  local nixbin
  drb="$(command -v darwin-rebuild || true)"
  if [ -z "$drb" ] && [ -x "/etc/profiles/per-user/$USER/bin/darwin-rebuild" ]; then
    drb="/etc/profiles/per-user/$USER/bin/darwin-rebuild"
  fi
  if [ -z "$drb" ] && [ -x "/nix/var/nix/profiles/default/bin/darwin-rebuild" ]; then
    drb="/nix/var/nix/profiles/default/bin/darwin-rebuild"
  fi
  if [ -n "$drb" ]; then
    sudo "$drb" switch --flake "$HOME/projects/nixos-dotfiles#fulgrim"
  else
    nixbin="$(command -v nix || true)"
    if [ -z "$nixbin" ] && [ -x "/nix/var/nix/profiles/default/bin/nix" ]; then
      nixbin="/nix/var/nix/profiles/default/bin/nix"
    fi
    if [ -z "$nixbin" ]; then
      echo "nix not found in PATH"
      return 1
    fi
    sudo -H "$nixbin" --extra-experimental-features "nix-command flakes" \
      run nix-darwin -- switch --flake "$HOME/projects/nixos-dotfiles#fulgrim"
  fi
}

# Shell integrations
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init --cmd cd zsh)"
fi
