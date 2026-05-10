{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../common/zerotier.nix
    ./remote-builder.nix
    ../common/modules
    ../common/get-remote-build.nix
    #./remote-vacation.nix
    ./airplay.nix
  ];

  modules = {
    nix-helpers.enable = true;
    desktop = {
      #ly.enable = true;
      niri.enable = true;
      gnome.enable = true;
      hyprland.enable = false;
    };
    programs = {
      git.enable = true;
      chess.enable = true;
      thunar.enable = true;
      obsidian.enable = true;
      texlive.enable = true;
      gaming.enable = true;
      ghostty.enable = true;
      nixvim.enable = true;
      firefox.enable = true;
      zen.enable = true;
      rofi.enable = true;
      zsh.enable = true;
      zathura.enable = true;
      waybar.enable = true;
      kanata = {
        enable = true;
        devices = [
          "/dev/input/by-path/pci-0000:02:00.0-usb-0:2:1.1-event-kbd"
          "/dev/input/by-path/pci-0000:02:00.0-usb-0:3:1.0-event-kbd"
          "/dev/input/by-id/usb-Compx_2.4G_Wireless_Receiver-event-kbd"
        ];
      };
    };
    theme.stylix = {
      enable = true;
      scheme = "${pkgs.base16-schemes}/share/themes/everforest-dark-soft.yaml";
    };
    startup.programs = [
      "nm-applet --indicator"
      "waybar"
      "dunst"
      "blueman-applet"
      "gammastep-indicator -l 45.068371:7.683070"
      "hacompanion"
      "owncloud"
      "openrgb --startminimized"
    ];
  };
  programs.ssh.extraConfig = ''
    Host eu.nixbuild.net
    PubkeyAcceptedKeyTypes ssh-ed25519
    ServerAliveInterval 60
    IPQoS throughput
    IdentityFile /home/lorev/.ssh/nixbuild-key
  '';
  programs.corectrl.enable = true;

  programs.ssh.knownHosts = {
    nixbuild = {
      hostNames = ["eu.nixbuild.net"];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
    };
  };

  nix = {
    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "eu.nixbuild.net";
        system = "x86_64-linux";
        maxJobs = 100;
        supportedFeatures = ["benchmark" "big-parallel"];
      }
    ];
  };
  boot = {
    initrd.kernelModules = ["amdgpu"];
    kernelParams = ["amdgpu.ppfeaturemask=0xffffffff"];
    kernel.sysctl."vm.max_map_count" = 2147483642;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
  };
  time.hardwareClockInLocalTime = true;

  networking.hostName = "AMDnixos";
  nix.settings = {
    download-buffer-size = 524288000;
    experimental-features = ["nix-command" "flakes"];
    substituters = [
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Rome";
  i18n.defaultLocale = "it_IT.UTF-8";
  i18n.extraLocaleSettings = {
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
  hardware = {
    i2c.enable = true;
    amdgpu = {
      opencl.enable = true;
      overdrive.enable = true;
      initrd.enable = true;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
  services = {
    usbmuxd.enable = true;
    displayManager.gdm = {
      enable = true;
      settings.daemon.DisplaysMode = "mirror";
    };
    hardware.openrgb.enable = true;
    lact.enable = true;
    xserver = {
      enable = true;
      videoDrivers = ["amdgpu"];
    };
    printing.enable = false;
    tailscale = {
      enable = true;
      useRoutingFeatures = "both";
    };
  };

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.lorev = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Lorenzo Pasqui";
    hashedPassword = "$y$j9T$/Zd2ewjXuVjuKz3YzWA3L/$iUOruuv0a6FT1QjzY1ZhTI5OkBxX88ZHXdpAJ6.tBk4";
    extraGroups = ["networkmanager" "wheel" "corectrl"];
  };

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

    gemini-cli
    clinfo
    vim
    openrgb-with-all-plugins
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
    sops
    zathura
    htop-vim
    jq
    openresolv
    nixd
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
  ];
  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    nerd-fonts.fira-code
    nerd-fonts.mononoki
  ];
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };
  system.stateVersion = "25.11";
}
