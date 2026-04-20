{ config, pkgs, lib, primaryUser, linuxHome, ... }:
let
  dotfiles = "${config.home.homeDirectory}/projects/nixos-dotfiles/config";
  createSymlink = path: config.lib.file.mkOutOfStoreSymlink path;

  configs = {
    emacs = "emacs-kick";
    nvim = "nvim";
    starship = "starship";
    tmux = "tmux";
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
        nix-search-tv
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

  home.file.".emacs.d/init.el" = {
    source = createSymlink "${dotfiles}/emacs-kick/init.el";
  };

  xdg.configFile = builtins.mapAttrs
    (_name: subpath: {
      source = createSymlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs;
}
