Drop upstream `dwl` patch files here.

Any `*.patch` file in this directory is appended to the `dwl` package build for `horus`.

Workflow:

1. Add or remove patch files in this directory.
2. Edit [config.h](/Users/tim/projects/nixos-dotfiles/hosts/horus/dwl/config.h) for normal dwl key/layout settings.
3. Rebuild with `sudo nixos-rebuild switch --flake ~/nixos-dotfiles#horus`.
