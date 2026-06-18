{ config
, pkgs
, lib
, primaryUser
, linuxHome
, extraPackages ? [ ]
, extraConfigs ? { }
, extraFiles ? { }
, ...
}:
let
  dotfiles = "${config.home.homeDirectory}/projects/nixos-dotfiles/config";
  createSymlink = path: config.lib.file.mkOutOfStoreSymlink path;

  commonConfigs = {
    emacs = "emacs-kick";
    hypr = "hypr";
    nvim = "nvim";
    starship = "starship";
    swaylock = "swaylock";
    tmux = "tmux";
  } // extraConfigs;

  commonPackages = with pkgs; [
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
    neovim
    nitch
    nixpkgs-fmt
    pcmanfm
    ripgrep
    starship
    swaylock-effects
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
  ] ++ extraPackages;
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

  home.packages = commonPackages;

  home.file = {
    ".bashrc".source = createSymlink "${dotfiles}/bash/.bashrc";
    ".bash_profile".source = createSymlink "${dotfiles}/bash/.bash_profile";

    # Emacs still prefers ~/.emacs.d/init.el when ~/.emacs.d exists.
    # Keep config source in ~/.config/emacs (xdg) and bridge with a shim.
    ".emacs.d/init.el".source = createSymlink "${dotfiles}/emacs-kick/init.el";

    "pictures/walls/.keep".text = "";
  } // extraFiles;

  xdg.configFile = builtins.mapAttrs
    (_name: subpath: {
      source = createSymlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    commonConfigs;

  home.activation.ensureBootstrapDirs = lib.hm.dag.entryBefore [ "dconfSettings" ] ''
    mkdir -p "$HOME/.config/dconf" "$HOME/.config/age" "$HOME/.config/isync" "$HOME/.config/msmtp"
  '';
}
