# NixOS and dotfiles

This repository manages three NixOS hosts and shares user configuration with a
MacBook. Keep it as one repository while those systems continue to share the
same applications, secrets, and configuration.

## Layout

- `hosts/`: machine facts such as hardware, hostnames, disks, and networking.
- `modules/nixos/profiles/`: reusable capabilities selected by desktop hosts.
- `modules/homelab/`: the reusable server role and its service modules.
- `modules/home/`: small Home Manager capabilities such as packages, GPG, and
  dotfile linking.
- `homes/`: platform and machine compositions built from those capabilities.
- `config/`: live application configuration shared by NixOS and macOS.
- `secrets/`: encrypted Agenix payloads and recipient declarations.

Hosts should primarily select modules and declare machine-specific values.
Reusable behaviour belongs in a profile or service module instead.

## Hosts

| Flake output | Hostname | Purpose |
| --- | --- | --- |
| `horus` | `horus` | NVIDIA desktop/workstation |
| `laptop` | `nixos` | NixOS laptop |
| `eisenstein` | `eisenstein` | Homelab server |

Build a host without switching it:

```bash
nix build .#nixosConfigurations.horus.config.system.build.toplevel
```

Apply the configuration on the matching machine:

```bash
sudo nixos-rebuild switch --flake .#horus
```

## Live dotfiles

Home Manager intentionally creates out-of-store symlinks, so edits under
`config/` take effect without rebuilding the system. The default checkout is
`~/projects/nixos-dotfiles`; override `dotfilesRoot` in the relevant `mkHost`
call in `flake.nix` if the repository moves.

macOS remains bootstrap-based rather than Nix-managed. See [MACOS.md](MACOS.md).

## Home Manager layers

The Home Manager import chain is deliberately explicit:

```text
common.nix
  portable packages, GPG, and portable dotfiles
       |
linux.nix
  Linux GPG agent and Linux bootstrap directories
       |
linux-desktop.nix
  GTK theme and graphical Linux packages
       |
hyprland.nix
  Hyprland packages and Hyprland/Swaylock dotfiles
       |
horus.nix / laptop.nix
  packages and dotfiles unique to that machine
```

`common.nix` must not acquire Linux desktop packages merely because both
current NixOS machines use them. A future macOS Home Manager profile can start
from `common.nix` without inheriting GTK, Hyprland, or a Linux GPG agent.

## Adding configuration

1. Put hardware and network identity in `hosts/<host>/`.
2. Put reusable NixOS behaviour in `modules/nixos/profiles/`.
3. Put server-role services in `modules/homelab/`.
4. Put reusable user behaviour in `modules/home/`, then select it from the
   narrowest appropriate file under `homes/`.
5. Keep application-native files in `config/` when macOS also consumes them.
