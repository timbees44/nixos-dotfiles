{ config, pkgs, lib, primaryUser, linuxHome, ... }:
let
  dotfiles = "${config.home.homeDirectory}/projects/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;

  configs = {
    emacs = "emacs-kick";
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

  home.username = primaryUser;
  home.homeDirectory = linuxHome;
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
    emacsPackages.pdf-tools
    eza
    fd
    fzf
    gcc
    gnumake
    hypridle
    hyprpaper
    isync
    jq
    msmtp
    mu
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
        nix-search-tv
      ];
      text = ''exec "${pkgs.nix-search-tv.src}/nixpkgs.sh" "$@"'';
    })
  ]) ++ lib.optionals (pkgs.mu ? emacs) [ pkgs.mu.emacs ]
    ++ lib.optionals (pkgs ? mu4e) [ pkgs.mu4e ];

  home.file.".bashrc" = {
    source = create_symlink "${dotfiles}/bash/.bashrc";
  };

  home.file.".bash_profile" = {
    source = create_symlink "${dotfiles}/bash/.bash_profile";
  };

  home.file.".emacs.d/init.el" = {
    source = create_symlink "${dotfiles}/emacs-kick/init.el";
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

  home.activation.ensureBootstrapDirs = lib.hm.dag.entryBefore [ "dconfSettings" ] ''
    mkdir -p "$HOME/.config/dconf" "$HOME/.config/age" "$HOME/.config/isync" "$HOME/.config/msmtp"
  '';
}
