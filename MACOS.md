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
- `~/.config/sketchybar`
- `~/pictures/walls/prometheus.png`

It also installs the `kanata` formula, installs/activates the matching macOS
VirtualHID driver, and starts the Kanata service. Kanata owns laptop keyboard
behavior, and Corne behavior belongs in ZMK.

## Kanata Home-Row Mods

The home-row mod config lives at:

```bash
~/.config/kanata/kanata.kbd
```

Test it manually before enabling it at login:

```bash
sudo /opt/homebrew/opt/kanata/bin/kanata --no-wait --cfg ~/.config/kanata/kanata.kbd
```

Kanata on macOS still needs Karabiner's standalone virtual HID output driver. The
bootstrap script installs and activates `Karabiner-DriverKit-VirtualHIDDevice`
`v6.2.0`, which matches Kanata 1.12.0. Do not install Karabiner Elements for this;
the current v7 driver changed the DriverKit IPC protocol, which shows up as
repeated `connect_failed asio.system:2` and `output backend unavailable` in
Kanata logs.

The package source is:

```text
https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases/tag/v6.2.0
```

The config is scoped with `macos-dev-names-include` so it should only intercept
the built-in Apple keyboard. Kanata still uses the Karabiner VirtualHID driver
for output on macOS, but the virtual output keyboard should not be listed as an
input device. If Kanata exits because it cannot find the built-in keyboard, list
the exact names and update `macos-dev-names-include`:

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
- `d` / `k`: Option
- `f` / `j`: Control

Same-hand rolls are biased toward taps so normal typing should keep letters.
Deliberate modifier chords should be typed by holding the home-row key briefly
before pressing the chord key. Once the timings feel right, start it at login:

```bash
sudo brew services start kanata
```

## Corne Cmd/Option Swap

The Corne-specific left Command/Option swap is handled outside Kanata with
macOS `hidutil`, so the built-in Mac keyboard remains scoped to the Kanata
home-row config above. The script targets only the Corne HID keyboard device:

```bash
config/scripts/corne-cmd-option-swap.sh
```

The bootstrap installs a user LaunchAgent that reapplies the mapping at login
and once per minute, which covers Bluetooth reconnects.

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
