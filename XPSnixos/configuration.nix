{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./services/homepage.nix
    ../common/sops.nix
    ../common/zerotier.nix
    ./graphics.nix
    ../common/distributed-builds.nix
    ../common/get-remote-build.nix
    ../common/modules
  ];
  modules = {
    nix-helpers.enable = true;
    desktop = {
      niri.enable = true;
      gnome.enable = true;
      hyprland.enable = false;
      ly.enable = true;
    };
    programs = {
      thunar.enable = true;
      obsidian.enable = true;
      texlive.enable = true;
      gaming.enable = true;
      ghostty.enable = true;
      nixvim.enable = true;
      firefox.enable = true;
      rofi.enable = true;
      zathura.enable = true;
      zsh.enable = true;
      waybar.enable = true;
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
  };

  boot = {
    resumeDevice = "/dev/disk/by-uuid/fdc651ed-f77f-4e32-98eb-a24a7a021853";
    kernelParams = [
      "resume_offset=80377856"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia.NVreg_TemporaryFilePath=/var/tmp"
    ];
    # Bootloader.
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
    hostName = "XPSnixos"; # Define your hostname.
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [8080 8081 5829 8096 3000];
      #allowedUDPPorts = [ ... ];
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

  # Enable network manager applet
  programs = {
    nm-applet.enable = true;

    nix-ld.enable = true;
    nix-ld.libraries = with pkgs; [
      # Add any missing dynamic libraries for unpackaged programs
      # here, NOT in environment.systemPackages
      icu
    ];
  };
  # Set your time zone.
  time.timeZone = "Europe/Rome";

  # Select internationalisation properties.
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
    fprintd = {
      enable = true;
      package = pkgs.fprintd-tod;
      tod = {
        enable = true;
        driver = pkgs.libfprint-2-tod1-goodix;
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
      #displayManager.ly = {
      #  enable = false;
      #  settings = {
      #    animation = "matrix";
      #    animation_timeout_sec = 10;
      #    asterisk = "\#";
      #    auth_fails = 3;
      #    bigclock = "en";
      #    clear_password = true;
      #    clock = "%a %d %b %R";
      #    lang = "it";
      #  };
      #};
      xkb = {
        layout = "it";
        variant = "";
      };
    };
    displayManager.gdm = {
      enable = true;
      settings.daemon.DisplaysMode = "mirror";
    };
    envfs.enable = true;

    # Disable CUPS to never print documents.
    printing.enable = false;
    tailscale = {
      enable = true;
      useRoutingFeatures = "both";
    };
  };

  # Configure console keymap
  console.keyMap = "it2";

  security = {
    rtkit.enable = true;
    pam.services.gdm-password.enableGnomeKeyring = true;
  };
  users.users.lorev = {
    isNormalUser = true;
    description = "Lorenzo Pasqui";
    shell = pkgs.zsh;
    hashedPassword = "$y$j9T$/Zd2ewjXuVjuKz3YzWA3L/$iUOruuv0a6FT1QjzY1ZhTI5OkBxX88ZHXdpAJ6.tBk4";
    extraGroups = ["dialout" "libvirtd" "networkmanager" "wheel"];
  };

  programs.zsh.enable = true;

  programs.weylus = {
    enable = false;
    openFirewall = true;
    users = ["lorev"];
  };
  # Install Hyperland
  environment.sessionVariables = {
    # Wayland stuff
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["lorev"];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  hardware = {
    bluetooth.enable = true;
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    moonlight-qt
    vim
    git
    dunst
    libnotify
    swww
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
    zeroad
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
