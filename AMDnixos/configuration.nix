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
  ];

  modules = {
    nix-helpers.enable = true;
    desktop = {
      ly.enable = true;
      niri.enable = true;
      gnome.enable = true;
      hyprland.enable = false;
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
    extraGroups = ["networkmanager" "wheel"];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    gemini-cli
    clinfo
    vim
    openrgb-with-all-plugins
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
