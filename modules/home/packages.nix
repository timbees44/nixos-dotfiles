{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bat
    btop
    cmake
    codex
    emacs
    emacsPackages.pdf-tools
    eza
    fd
    fzf
    gcc
    gnumake
    isync
    jq
    msmtp
    neovim
    nixpkgs-fmt
    ripgrep
    starship
    tmux
    tree
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
}
