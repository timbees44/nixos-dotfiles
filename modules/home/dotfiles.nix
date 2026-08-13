{ config, lib, ... }:
let
  cfg = config.my.dotfiles;
  createSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configs = {
    emacs = "emacs-kick";
    nvim = "nvim";
    starship = "starship";
    tmux = "tmux";
  } // cfg.extraConfigs;
in
{
  options.my.dotfiles = {
    root = lib.mkOption {
      type = lib.types.str;
      description = "Absolute path to the live dotfiles config directory.";
    };

    extraConfigs = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Extra XDG config names mapped to directories below my.dotfiles.root.";
    };
  };

  config = {
    home.file = {
      ".bashrc".source = createSymlink "${cfg.root}/bash/.bashrc";
      ".bash_profile".source = createSymlink "${cfg.root}/bash/.bash_profile";

      # Emacs still prefers ~/.emacs.d/init.el when ~/.emacs.d exists.
      ".emacs.d/init.el".source = createSymlink "${cfg.root}/emacs-kick/init.el";

      "pictures/walls/.keep".text = "";
    };

    xdg.configFile = builtins.mapAttrs
      (_name: subpath: {
        source = createSymlink "${cfg.root}/${subpath}";
        recursive = true;
      })
      configs;
  };
}
