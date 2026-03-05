{ config, pkgs, lib, doomemacs, ... }:
let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  doomDir = "${config.home.homeDirectory}/.emacs.d";

  configs = {
    doom = "doom";
    hypr = "hypr";
    nvim = "nvim";
    starship = "starship";
    tmux = "tmux";
    waybar = "waybar";
    wezterm = "wezterm";
    wofi = "wofi";
    swaylock = "swaylock";
  };
in
{
  imports = [
    ../modules/theme.nix
  ];

  home.username = "tim";
  home.homeDirectory = "/home/tim";
  home.stateVersion = "24.05";

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };

  home.packages = with pkgs; [
    bat
		brave
		btop
		cmake
    codex
		deluge
    emacs
    eza
    fzf
    gcc
    gnumake
    hypridle
    hyprpaper
    jq
    neovim
    nitch
    nixpkgs-fmt
    pcmanfm
    ripgrep
    starship
    swaylock-effects
    tmux
    tree
    waybar
    wezterm
    wofi
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
    source = create_symlink "${dotfiles}/bash/.bashrc";
  };

  home.file.".bash_profile" = {
    source = create_symlink "${dotfiles}/bash/.bash_profile";
  };

  xdg.configFile = builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs;

  home.file."pictures/walls/.keep" = {
    text = "";
  };

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

  home.activation.doomSync = lib.hm.dag.entryAfter [ "doomInstall" ] ''
    doomBin="${doomDir}/bin/doom"
    if [ -x "$doomBin" ]; then
      export PATH=${lib.makeBinPath [ pkgs.emacs pkgs.git pkgs.gnutar pkgs.gzip pkgs.coreutils ]}:$PATH
      "$doomBin" sync || true
    fi
  '';

}
