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

If `~/.config/age/keys.txt` already exists, that same command now also decrypts
the local mail configs automatically.

If you also want the optional macOS UI config and wallpaper:

```bash
./config/scripts/bootstrap-macos.sh --with-ui
```

## What it sets up

- `~/.zshrc`
- `~/.zprofile`
- `~/.config/emacs`
- `~/.config/nvim`
- `~/.config/starship`
- `~/.config/tmux`
- `~/.config/wezterm`
- `~/.emacs`
- `~/.emacs.d/init.el`

Optional `--with-ui` also links:

- `~/.config/aerospace`
- `~/.config/kanata`
- `~/.config/karabiner`
- `~/.config/sketchybar`
- `~/pictures/walls/prometheus.png`

It also installs the `kanata` formula and Karabiner Elements. Kanata uses the
Karabiner driver on macOS, while `~/.config/karabiner` stays limited to simple
Karabiner-specific mappings such as device-specific modifier swaps.

## Kanata Home-Row Mods

The home-row mod config lives at:

```bash
~/.config/kanata/kanata.kbd
```

Test it manually before enabling it at login:

```bash
sudo /opt/homebrew/opt/kanata/bin/kanata --no-wait --cfg ~/.config/kanata/kanata.kbd
```

The config is scoped with `macos-dev-names-include` so it should only intercept
the built-in Apple keyboard. If Kanata exits because it cannot find that device,
list the exact names and update `macos-dev-names-include`:

```bash
/opt/homebrew/opt/kanata/bin/kanata --list
```

Validate config changes without starting the remapper:

```bash
/opt/homebrew/opt/kanata/bin/kanata --check --cfg ~/.config/kanata/kanata.kbd
```

The configured home-row holds are:

- `a` / `;`: Shift
- `s` / `l`: Command
- `d` / `k`: Control
- `f` / `j`: Option

Same-hand rolls are biased toward taps so normal typing should keep letters.
Deliberate modifier chords should be typed by holding the home-row key briefly
before pressing the chord key. Once the timings feel right, start it at login:

```bash
sudo brew services start kanata
```

## Mail Secrets

If you only want to materialize the local mail configs without rerunning the full
bootstrap:

```bash
./config/scripts/bootstrap-macos.sh --mail-secrets-only
```

That writes:

- `~/.config/isync/mbsyncrc`
- `~/.config/msmtp/config`

If your local Maildir is empty, sync and index it with:

```bash
mbsync -c ~/.config/isync/mbsyncrc gmail
mu init --maildir=~/.mail --my-address=<your-email>
mu index
```

If you only want to refresh the local GPG agent/SSH socket wiring:

```bash
./config/scripts/bootstrap-macos.sh --refresh-gpg-agent-only
```

## Notes

- The current macOS shell setup is intentionally minimal and mirrors the Bash
  setup instead of using a shell framework.
- If the Nix user profile on macOS breaks, the shell still works because it can
  fall back to the Darwin system profile path for tools like `nvim`.
- The macOS bootstrap installs `age`, `mu`, `isync`, and `msmtp`, and it can
  decrypt the same repo-managed secrets used by your Nix hosts without
  requiring `nix-darwin`.
- The shared Emacs config will use `mu4e` once the mail secrets exist locally
  and the Maildir has been synced/indexed.
