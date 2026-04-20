# macOS Setup

This repo is Linux-first. For macOS the goal is to keep the same editor/shell
workflow without depending on a full Nix user environment.

## Recommended model

- Use the shared configs in `config/` for shell, Emacs, Neovim, tmux, WezTerm.
- Use Homebrew for package installation on macOS.
- Keep macOS-only UI config optional.
- Treat `nix-darwin` and Home Manager on macOS as optional, not foundational.

## Bootstrap

Install Homebrew first if it is not already installed:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Run the bootstrap script from the repo:

```bash
./config/scripts/bootstrap-macos.sh
```

If you also want the optional macOS UI config and wallpaper:

```bash
./config/scripts/bootstrap-macos.sh --with-ui
```

## What it sets up

- `~/.zshrc`
- `~/.zprofile`
- `~/.bashrc`
- `~/.bash_profile`
- `~/.config/emacs`
- `~/.config/nvim`
- `~/.config/starship`
- `~/.config/tmux`
- `~/.config/wezterm`
- `~/.emacs`
- `~/.emacs.d/init.el`

Optional `--with-ui` also links:

- `~/.config/aerospace`
- `~/.config/karabiner`
- `~/.config/sketchybar`
- `~/pictures/walls/prometheus.png`

## Notes

- The current macOS shell setup is intentionally minimal and mirrors the Bash
  setup instead of using a shell framework.
- If the Nix user profile on macOS breaks, the shell still works because it can
  fall back to the Darwin system profile path for tools like `nvim`.
