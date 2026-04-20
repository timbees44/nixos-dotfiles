{ config, pkgs, lib, primaryUser, darwinHome, ... }:
let
  # Dotfiles repo checkout location on macOS.
  dotfiles = "${config.home.homeDirectory}/projects/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;

  # Config directories to expose under ~/.config via symlinks.
  configs = {
    aerospace = "aerospace";
    emacs = "emacs-kick";
    karabiner = "karabiner";
    nvim = "nvim";
    sketchybar = "sketchybar";
    starship = "starship";
    tmux = "tmux";
    wezterm = "wezterm";
  };

  # Cross-platform CLI/editor tooling.
  commonPkgs = with pkgs; [
    aspell
    automake
    bat
    btop
    cargo-update
    cmake
    codex
    coreutils
    eza
    fd
    fzf
    gcc
    gawk
    gnupg
    gnugrep
    gnused
    gnumake
    gnutar
    jq
    libtool
    isync
    msmtp
    mu
    neovim
    nixpkgs-fmt
    nmap
    nodejs_22
    pkg-config
    poppler
    ripgrep
    skim
    starship
    stow
    texinfo
    tmux
    tree
    yubikey-manager
    wezterm
    zoxide
  ];

  # macOS-specific additions.
  macPkgs = with pkgs; [
    openvpn
  ];
in
{
  home.username = primaryUser;
  home.homeDirectory = darwinHome;
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
  home.packages = commonPkgs ++ macPkgs
    ++ lib.optionals (pkgs.mu ? emacs) [ pkgs.mu.emacs ]
    ++ lib.optionals (pkgs ? mu4e) [ pkgs.mu4e ]
    ++ [
    (pkgs.writeShellApplication {
      name = "ns";
      runtimeInputs = with pkgs; [
        fzf
        nix-search-tv
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

  # Keep zsh startup local to the Home Manager generation on macOS.
  # This avoids prompt startup breaking if the out-of-store repo symlink
  # is missing or stale on the host.
  home.file.".zshrc".text = builtins.readFile ../config/zsh/.zshrc;

  home.file.".zprofile".text = builtins.readFile ../config/zsh/.zprofile;

  # Emacs still prefers ~/.emacs.d/init.el when ~/.emacs.d exists.
  # Keep config source in ~/.config/emacs (xdg) and bridge with a shim.
  home.file.".emacs.d/init.el" = {
    source = create_symlink "${dotfiles}/emacs-kick/init.el";
  };

  # Some mail tooling still probes ~/.config/isyncrc as an mbsync fallback.
  # Keep a compatibility link to the real XDG config file.
  home.file.".config/isyncrc" = {
    source = create_symlink "${config.home.homeDirectory}/.config/isync/mbsyncrc";
  };

  # Create ~/.config/* links from the `configs` attrset above.
  xdg.configFile = builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs;

  home.file."pictures/walls/.keep" = {
    text = "";
  };

  home.file."pictures/walls/prometheus.png" = {
    source = create_symlink "${dotfiles}/walls/prometheus.png";
  };

  home.activation.setMacWallpaper = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    wallpaper="$HOME/pictures/walls/prometheus.png"
    if [ -f "$wallpaper" ]; then
      /usr/bin/osascript <<EOF
tell application "System Events"
  tell every desktop
    set picture to POSIX file "$wallpaper"
  end tell
end tell
EOF
    fi
  '';
}
