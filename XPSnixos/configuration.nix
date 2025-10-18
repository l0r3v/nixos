{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./services/homepage.nix
    ./services/kanata.nix
    ../common/nix-helpers.nix
    ../common/sops.nix
    ../common/nix-maintenance.nix
    ../common/zerotier.nix
    ./programs/stylix.nix
    ./graphics.nix
  ];
  boot = {
    resumeDevice = "/dev/disk/by-uuid/fdc651ed-f77f-4e32-98eb-a24a7a021853";
    kernelParams = ["resume_offset=80377856"];
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
      allowedTCPPorts = [8080 8081 5829 8096];
      #allowedUDPPorts = [ ... ];
    };
  };

  nix.settings = {
    download-buffer-size = 524288000;
    experimental-features = ["nix-command" "flakes"];
    substituters = [
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
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
    preload.enable = true;
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

  programs.adb.enable = true;
  programs.zsh.enable = true;

  programs.weylus = {
    enable = false;
    openFirewall = true;
    users = ["lorev"];
  };

  # Install Hyperland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
  };
  environment.sessionVariables = {
    # Wayland stuff
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    #my sessionVariables
    EDITOR = "nvim";
  };
  # configuration.nix
  systemd.user.services."lid-monitor" = {
    description = "Lid close monitor handler";
    script = ''
      #!/usr/bin/env bash
      LID_STATE=$(cat /proc/acpi/button/lid/*/state | awk '{print $2}')
      EXTERNAL=$(hyprctl monitors -j | jq '[.[] | select(.name!="eDP-1" and .active)] | length')
      if [[ "$LID_STATE" == "closed" && "$EXTERNAL" -gt 0 ]]; then
        hyprctl keyword monitor "eDP-1,disable"
      elif [[ "$LID_STATE" == "open" ]]; then
        hyprctl keyword monitor "eDP-1,preferred,auto-left,1"
      fi
    '';
    wantedBy = ["tray.target"];
    serviceConfig = {
      Type = "oneshot";
    };
  };

  services.udev.extraRules = ''
    ACTION=="change", SUBSYSTEM=="power_supply", KERNEL=="*lid*", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}+="lid-monitor.service"
  '';

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
    zathura
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
    steam-tui
    socat
    ags
    playerctl
    yafc-ce
    zeroad
  ];
  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [thunar-archive-plugin thunar-volman thunar-bare thunar-vcs-plugin];
  };

  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    nerd-fonts.fira-code
    nerd-fonts.mononoki
  ];
  xdg.mime.defaultApplications = {
    "text/html" = "org.qutebrowser.qutebrowser.desktop";
    "x-scheme-handler/http" = "org.qutebrowser.qutebrowser.desktop";
    "x-scheme-handler/https" = "org.qutebrowser.qutebrowser.desktop";
    "x-scheme-handler/about" = "org.qutebrowser.qutebrowser.desktop";
    "x-scheme-handler/unknown" = "org.qutebrowser.qutebrowser.desktop";
  };
  #Install Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };
  system.stateVersion = "24.05"; # Do not change this
}
