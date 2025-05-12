{
  config,
  pkgs,
  inputs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
  nixvim-package = inputs.nixvim.packages.${system}.full;
  extended-nixvim = nixvim-package.extend config.lib.stylix.nixvim.config;
in {
  home = {
    username = "lorev";
    homeDirectory = "/home/lorev";
    packages = [
      #FROM FLAKES
      extended-nixvim
      inputs.yt-x.packages."${system}".default
      inputs.inkscape-figures.packages."${system}".inkscape-figures
      inputs.university-setup.packages."${system}".default

      pkgs.htop-vim # system monitor with vim keybindings
      pkgs.zathura # pdf viewer with vim keybindings
      pkgs.eza #modern replacement for ls
      pkgs.fzf #cli fuzzy finder
      pkgs.yq
      pkgs.zoxide
      pkgs.dropbox
      pkgs.tlrc
      pkgs.vlc
      pkgs.graphicsmagick
      pkgs.grim
      pkgs.slurp
      pkgs.zenity
      pkgs.wl-clipboard
      pkgs.unzip
      pkgs.telegram-desktop
      pkgs.headsetcontrol
      pkgs.gh
      pkgs.libsecret
      pkgs.nchat
      pkgs.ripgrep
      pkgs.blueman
      pkgs.stremio
      pkgs.kitty
      pkgs.alejandra
      pkgs.base16-schemes
      pkgs.onedrive
      pkgs.viu
      pkgs.vimiv-qt
      pkgs.gammastep
      pkgs.tut
      pkgs.clang
      pkgs.ytfzf
      pkgs.calibre
      pkgs.whatsie
      pkgs.bitwarden
      pkgs.rclone
      pkgs.rclone-browser
      pkgs.chromium
      pkgs.localsend
      pkgs.libreoffice-qt
      pkgs.gimp
      pkgs.hacompanion
      pkgs.speedtest-cli
      pkgs.ckan
      pkgs.prismlauncher
      pkgs.audacity
      pkgs.inkscape
      pkgs.latexrun
      pkgs.xdotool
      pkgs.discord
      pkgs.newsflash
      pkgs.nix-init
      pkgs.owncloud-client
      pkgs.aria2
      pkgs.vscodium
      pkgs.preload
      pkgs.vorta
      pkgs.gcr
      pkgs.seahorse
    ]; #END OF PACKAGES
  };

  programs = {
    btop.enable = true;
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
    eza = {
      enable = true;
      icons = "auto";
      git = true;
    };
    ssh = {
      enable = true;
      addKeysToAgent = "confirm";
      forwardAgent = true;
      extraConfig = ''
        Host homelab-git
          HostName homelab.tail0e73ab.ts.net
          user git
          Port 2221
          IdentityFile /home/lorev/.ssh/id_ed25519
      '';
    };

    git = {
      enable = true;
      userName = "lorev";
      userEmail = "lorenzopasqui@gmail.com";
      extraConfig = {
        credential.helper = "${
          pkgs.git.override {withLibsecret = true;}
        }/bin/git-credential-libsecret";
        push = {autoSetupRemote = true;};
      };
    };
    gitui = {
      enable = true;
      theme = ''
              (
            move_left: Some(( code: Char('h'), modifiers: "")),
            move_right: Some(( code: Char('l'), modifiers: "")),
            move_up: Some(( code: Char('k'), modifiers: "")),
            move_down: Some(( code: Char('j'), modifiers: "")),

            stash_open: Some(( code: Char('l'), modifiers: "")),
            open_help: Some(( code: F(1), modifiers: "")),

            status_reset_item: Some(( code: Char('U'), modifiers: "SHIFT")),
        )
      '';
    };

    bash = {
      enable = true;
      enableCompletion = true;
      bashrcExtra = ''
             export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
             function zathura() {
             		nohup zathura "$@" > /dev/null 2>&1 &
        	disown
        	exit
        	}
          export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
             function vli() {
             		nohup vlc "$@" > /dev/null 2>&1 &
        	disown
        	exit
        	}
        eval "$(zoxide init --cmd cd bash)"
        if command -v fzf-share >/dev/null; then
          source "$(fzf-share)/key-bindings.bash"
          source "$(fzf-share)/completion.bash"
        fi
      '';
      shellAliases = {
        shtdwn = "shutdown now";
        ls = "eza";
        ll = "eza -la";
        ett = "eza --tree";
        zi = "zathura";
        tssh = "tailscale ssh hspasqui@homelab";
        ts = "tailscale";
      };
    };
    java.enable = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    XDG_CONFIG_HOME = "/home/lorev/.config";
  };

  imports = [
    ./config/files.nix
    ./programs
  ];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
