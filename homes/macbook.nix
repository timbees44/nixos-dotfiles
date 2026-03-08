{ config, pkgs, lib, doomemacs, ... }:
let
  # Dotfiles repo checkout location on macOS.
  dotfiles = "${config.home.homeDirectory}/projects/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  # Doom framework install destination.
  doomDir = "${config.home.homeDirectory}/.emacs.d";

  # Config directories to expose under ~/.config via symlinks.
  configs = {
    doom = "doom";
    nvim = "nvim";
    starship = "starship";
    tmux = "tmux";
    wezterm = "wezterm";
  };
in
{
  home.username = "tim";
  home.homeDirectory = "/Users/tim";
  # Home Manager compatibility baseline.
  home.stateVersion = "24.05";

  # GPG agent setup suitable for macOS key prompts.
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry_mac;
  };

  # User-facing packages managed by Home Manager.
  home.packages = with pkgs; [
    bat
    btop
    cmake
    codex
    emacs
    eza
    fzf
    gcc
    gnumake
    jq
    neovim
    nixpkgs-fmt
    ripgrep
    starship
    tmux
    tree
    wezterm
    zoxide
    (pkgs.writeShellApplication {
      name = "ns";
      runtimeInputs = with pkgs; [
        fzf
        (nix-search-tv.overrideAttrs {
          env.GOEXPERIMENT = "jsonv2";
        })
      ];
      text = ''exec "${pkgs.nix-search-tv.src}/nixpkgs.sh" "$@"'';
    })
  ];

  # Keep shell startup files sourced from the repo.
  home.file.".bashrc" = {
    source = create_symlink "${dotfiles}/bash/.bashrc";
  };

  home.file.".bash_profile" = {
    source = create_symlink "${dotfiles}/bash/.bash_profile";
  };

  # Provide legacy Doom path expected by some setups/tools.
  home.file.".doom.d" = {
    source = create_symlink "${dotfiles}/doom";
  };

  # Keep Doom CLI and Emacs aligned on the same config location.
  home.sessionVariables = {
    DOOMDIR = "${config.home.homeDirectory}/.config/doom";
  };

  # Create ~/.config/* links from the `configs` attrset above.
  xdg.configFile = builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs;

  # Install/update Doom core files on each activation.
  home.activation.doomInstall = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    doomSrc=${lib.escapeShellArg doomemacs}
    doomDest=${lib.escapeShellArg doomDir}
    mkdir -p "$doomDest"
    ${pkgs.rsync}/bin/rsync -a --delete \
      --chmod=Du+rwx,Fu+rw \
      --exclude='.local/' \
      "$doomSrc"/ "$doomDest"/
    for d in .local .local/etc .local/cache .local/state; do
      install -d -m 700 "$doomDest/$d"
    done
  '';

  # Sync Doom modules/packages after core files are in place.
  home.activation.doomSync = lib.hm.dag.entryAfter [ "doomInstall" ] ''
    doomBin="${doomDir}/bin/doom"
    if [ -x "$doomBin" ]; then
      export PATH=${lib.makeBinPath [ pkgs.emacs pkgs.git pkgs.gnutar pkgs.gzip pkgs.coreutils ]}:$PATH
      "$doomBin" sync || true
    fi
  '';
}
