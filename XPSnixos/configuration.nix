{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./services/homepage.nix
    ../common/sops.nix
    ../common/zerotier.nix
    ./graphics.nix
    ../common/nixbuild.nix
    ../common/get-remote-build.nix
    ../common/modules
  ];
  modules = {
    nix-helpers.enable = true;
    desktop = {
      greetd.enable = true;
      polkit.enable = true;
      niri.enable = true;
      hyprland.enable = false;
    };
    programs = {
      chess.enable = true;
      firefox.enable = true;
      game-dev.enable = true;
      gaming.enable = true;
      ghostty.enable = true;
      git.enable = true;
      tmux.enable = true;
      nixvim.enable = true;
      obsidian.enable = true;
      rofi.enable = true;
      rofi-rbw.enable = true;
      ssh.enable = true;
      texlive.enable = true;
      thunar.enable = true;
      waybar.enable = true;
      zathura.enable = true;
      zen.enable = true;
      zsh.enable = true;
      kanata = {
        enable = true;
        devices = [
        ];
      };
    };
    theme.stylix = {
      enable = true;
      scheme = "${pkgs.base16-schemes}/share/themes/espresso.yaml";
    };
    startup.programs = [
      "nm-applet --indicator"
      "waybar"
      "dunst"
      "gammastep-indicator -l 45.068371:7.683070"
      "hacompanion"
      "owncloud"
    ];
  };

  boot = {
    resumeDevice = "/dev/disk/by-uuid/fdc651ed-f77f-4e32-98eb-a24a7a021853";
    kernelParams = [
      "resume_offset=80377856"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia.NVreg_TemporaryFilePath=/var/tmp"
    ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 16 * 1024; # 16 GB
    }
  ];
  networking = {
    hostName = "XPSnixos";
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [8080 8081 5829 8096 3000];
      extraCommands = ''
        iptables -A nixos-fw -p tcp --dport 22 -s 192.168.1.0/16 -j nixos-fw-accept
        iptables -A nixos-fw -p tcp --dport 22 -s 100.0.0.0/8 -j nixos-fw-accept
        iptables -A nixos-fw -p tcp --dport 22 -j nixos-fw-log-refuse
      '';
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.fail2ban = {
    enable = true;
    jails.sshd = {
      enabled = true;
      settings = {
        filter = "sshd";
        maxretry = 3;
        findtime = 600;
        bantime = 3600;
      };
    };
  };

  nix.settings = {
    download-buffer-size = 524288000;
    experimental-features = ["nix-command" "flakes"];
    substituters = [
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    trusted-users = ["root" "@wheel"];
  };

  programs = {
    nm-applet.enable = true;

    nix-ld.enable = true;
    nix-ld.libraries = with pkgs; [
      # Add any missing dynamic libraries for unpackaged programs
      # here, NOT in environment.systemPackages
      icu
    ];
  };
  time.timeZone = "Europe/Rome";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "it_IT.UTF-8";
      LC_IDENTIFICATION = "it_IT.UTF-8";
      LC_MEASUREMENT = "it_IT.UTF-8";
      LC_MONETARY = "it_IT.UTF-8";
      LC_NAME = "it_IT.UTF-8";
      LC_NUMERIC = "it_IT.UTF-8";
      LC_PAPER = "it_IT.UTF-8";
      LC_TELEPHONE = "it_IT.UTF-8";
      LC_TIME = "it_IT.UTF-8";
    };
  };

  services = {
    usbmuxd.enable = true;
    fprintd = {
      enable = true;
      package = pkgs.fprintd-tod;
      tod = {
        enable = true;
      };
    };
    blueman.enable = true;
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    power-profiles-daemon.enable = true;
    logind = {
      settings.Login.HandleLidSwitchDocked = "ignore";
    };
    flatpak.enable = true;
    xserver = {
      enable = true;
      xkb = {
        layout = "it";
        variant = "";
      };
    };
    envfs.enable = true;

    printing.enable = false;
    tailscale = {
      enable = true;
      useRoutingFeatures = "both";
    };
  };

  console.keyMap = "it2";

  security = {
    rtkit.enable = true;
  };
  users.users.lorev = {
    isNormalUser = true;
    description = "Lorenzo Pasqui";
    shell = pkgs.zsh;
    hashedPassword = "$y$j9T$/Zd2ewjXuVjuKz3YzWA3L/$iUOruuv0a6FT1QjzY1ZhTI5OkBxX88ZHXdpAJ6.tBk4";
    extraGroups = ["dialout" "libvirtd" "networkmanager" "wheel"];
  };

  programs.weylus = {
    enable = false;
    openFirewall = true;
    users = ["lorev"];
  };
  environment.sessionVariables = {
    # Wayland stuff
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  #programs.virt-manager.enable = true;
  #users.groups.libvirtd.members = ["lorev"];
  #virtualisation.libvirtd.enable = true;
  #virtualisation.spiceUSBRedirection.enable = true;

  hardware = {
    bluetooth.enable = true;
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    (pkgs.symlinkJoin {
      name = "librepods-wrapped";
      paths = [pkgs.librepods];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        for bin in $out/bin/*; do
          target=$(readlink -f "$bin")
          rm "$bin"
          makeWrapper "$target" "$bin" --unset QT_STYLE_OVERRIDE
        done
      '';
    })

    libsForQt5.qtstyleplugin-kvantum
    moonlight-qt
    vim
    git
    dunst
    libnotify
    awww
    networkmanagerapplet
    brightnessctl
    pavucontrol
    waybar
    jdk
    zoxide
    htop-vim
    jq
    openresolv
    nixd
    qemu
    sops
    nss
    wayland
    wayland-protocols
    wlroots
    libxkbcommon
    ripgrep
    socat
    ags
    playerctl
    yafc-ce
    tigervnc
  ];
  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    nerd-fonts.fira-code
    nerd-fonts.mononoki
  ];
  system.stateVersion = "24.05"; # Do not change this
}
