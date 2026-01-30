{
  pkgs,
  inputs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
in {
  home = {
    username = "lorev";
    homeDirectory = "/home/lorev";
    packages = [
      #FROM FLAKES
      inputs.yt-x.packages."${system}".default
      inputs.inkscape-figures.packages."${system}".inkscape-figures
      inputs.university-setup.packages."${system}".default

      pkgs.htop-vim # system monitor with vim keybindings
      pkgs.eza #modern replacement for ls
      pkgs.fzf #cli fuzzy finder
      pkgs.yq
      pkgs.protonup-qt
      pkgs.zoxide
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
      pkgs.ripgrep
      pkgs.blueman
      pkgs.alejandra
      pkgs.base16-schemes
      pkgs.onedrive
      pkgs.viu
      pkgs.vimiv-qt
      pkgs.gammastep
      pkgs.tut
      pkgs.clang
      pkgs.ytfzf
      pkgs.gimp
      pkgs.hacompanion
      pkgs.ckan
      pkgs.audacity
      pkgs.inkscape
      pkgs.latexrun
      pkgs.xdotool
      pkgs.newsflash
      (pkgs.owncloud-client.overrideAttrs (old: {
        buildInputs = (old.buildInputs or []) ++ [pkgs.adwaita-qt];
      }))
      pkgs.aria2
      pkgs.vorta
      pkgs.gcr
      pkgs.seahorse
      pkgs.lazygit
      pkgs.pinentry-curses
      pkgs.rbw
      pkgs.rofi-rbw-wayland
      pkgs.cloudflared
      pkgs.libqalculate
      pkgs.cider-2
      pkgs.tea
      pkgs.rofi-pulse-select
      pkgs.scid
      pkgs.stockfish
      pkgs.feishin
      pkgs.godot
      pkgs.blender
      pkgs.vscodium
      pkgs.aseprite
    ]; #END OF PACKAGES
  };

  programs = {
    fuzzel.enable = true;
    yazi = {
      enable = true;
    };

    keychain = {
      enable = true;
      enableZshIntegration = true;
      keys = [
        "~/.ssh/id_ed25519"
        "/home/lorev/.ssh/nixos-builder"
      ];
    };

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
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          forwardAgent = true;
          addKeysToAgent = "confirm";
          compression = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
          hashKnownHosts = false;
          userKnownHostsFile = "~/.ssh/known_hosts";
          controlMaster = "no";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "no";
        };
        "homelab-git" = {
          hostname = "homelab.tail0e73ab.ts.net";
          user = "git";
          port = 2221;
          identityFile = "/home/lorev/.ssh/id_ed25519";
        };
        "git.pasqui.casa" = {
          hostname = "git-ssh.pasqui.casa";
          user = "git";
          port = 2221;
          identityFile = "/home/lorev/.ssh/id_ed25519";
          proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
        };
        "xpsnixos.lan" = {
          hostname = "xpsnixos.lan";
          user = "nixos-builder";
          port = 22;
          identityFile = "/home/lorev/.ssh/nixos-builder";
        };
        "homelab.lan" = {
          hostname = "homelab.lan";
          user = "nixos-builder";
          port = 22;
          identityFile = "/home/lorev/.ssh/nixos-builder";
        };
        "git-ssh.pasqui.casa" = {
          hostname = "git-ssh.pasqui.casa";
          user = "git";
          port = 2221;
          identityFile = "/home/lorev/.ssh/id_ed25519";
          proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
        };
      };
    };

    git = {
      enable = true;
      settings = {
        user = {
          name = "lorev";
          email = "lorenzopasqui@gmail.com";
        };
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
    XDG_CONFIG_HOME = "/home/lorev/.config";
  };
  services.gnome-keyring = {
    enable = true;
    components = ["secrets" "pkcs11" "ssh"];
  };

  imports = [
    ./programs
  ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
}
