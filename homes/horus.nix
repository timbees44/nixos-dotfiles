{ config, pkgs, lib, doomemacs, ... }:
let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  doomDir = "${config.home.homeDirectory}/.emacs.d";

  configs = {
    doom = "doom";
    hypr = "hypr";
    foot = "foot";
    nvim = "nvim";
    starship = "starship";
    swaylock = "swaylock";
    tmux = "tmux";
  };
in
{
  imports = [
    ../modules/theme.nix
  ];

  home.username = "tim";
  home.homeDirectory = "/home/tim";
  home.stateVersion = "24.05";
  xdg.enable = true;

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };

  home.packages = (with pkgs; [
    bat
    bluetui
    brave
    btop
    cmake
    codex
    deluge
    emacs
    eza
    fd
    foot
    fzf
    gcc
    gnumake
    hypridle
    hyprpaper
    isync
    jq
    msmtp
    neovim
    nitch
    nixpkgs-fmt
    pcmanfm
    ripgrep
    starship
    swaylock-effects
    tmux
    tree
    wmenu
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
  ]);

  home.file.".bashrc" = {
    source = create_symlink "${dotfiles}/bash/.bashrc";
  };

  home.file.".bash_profile" = {
    source = create_symlink "${dotfiles}/bash/.bash_profile";
  };

  home.file.".doom.d" = {
    source = create_symlink "${dotfiles}/doom";
  };

  home.sessionVariables = {
    DOOMDIR = "${config.home.homeDirectory}/.config/doom";
  };

  xdg.configFile = builtins.mapAttrs
    (_name: subpath: {
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

  home.activation.ensureBootstrapDirs = lib.hm.dag.entryBefore [ "dconfSettings" ] ''
    mkdir -p "$HOME/.config/dconf" "$HOME/.config/age" "$HOME/.config/isync" "$HOME/.config/msmtp"
  '';

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

  home.activation.doomSync = lib.hm.dag.entryAfter [ "doomInstall" "linkGeneration" ] ''
    doomBin="${doomDir}/bin/doom"
    straightFile="${doomDir}/.local/straight/repos/straight.el/straight.el"
    if [ -x "$doomBin" ]; then
      export DOOMDIR="${config.home.homeDirectory}/.config/doom"
      export PATH=${lib.makeBinPath [ pkgs.emacs pkgs.git pkgs.gnutar pkgs.gzip pkgs.coreutils ]}:$PATH
      if [ ! -f "$straightFile" ]; then
        "$doomBin" install --force || true
      fi
      "$doomBin" sync || true
    fi
  '';
}
