{ config, pkgs, lib, doomemacs, ... }:
let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  createSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
  doomDir = "${config.home.homeDirectory}/.emacs.d";

  configs = {
    doom = "doom";
    nvim = "nvim";
    starship = "starship";
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
    pinentry.package = pkgs.pinentry-curses;
  };

  home.packages = with pkgs; [
    bat
    btop
    codex
    emacs
    eza
    fd
    fzf
    gcc
    git
    gnumake
    jq
    neovim
    nixpkgs-fmt
    ripgrep
    starship
    tmux
    tree
    wget
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

  home.file.".bashrc" = {
    source = createSymlink "${dotfiles}/bash/.bashrc";
  };

  home.file.".zshrc" = {
    source = createSymlink "${dotfiles}/zsh/.zshrc";
  };

  home.file.".zprofile" = {
    source = createSymlink "${dotfiles}/zsh/.zprofile";
  };

  home.file.".doom.d" = {
    source = createSymlink "${dotfiles}/doom";
  };

  home.sessionVariables = {
    DOOMDIR = "${config.home.homeDirectory}/.config/doom";
  };

  xdg.configFile = builtins.mapAttrs
    (_name: subpath: {
      source = createSymlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs;

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
