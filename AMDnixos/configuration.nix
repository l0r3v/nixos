# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../common/zerotier.nix
    ./remote-builder.nix
    ../common/modules
    #./remote-vacation.nix
  ];

  modules = {
    nix-helpers.enable = true;
    desktop = {
      niri.enable = true;
      gnome.enable = true;
      hyprland.enable = true;
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
  };
  # Boot
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

  networking.hostName = "AMDnixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
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

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Rome";

  # Select internationalisation properties.
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
  services.hardware.openrgb.enable = true;
  services = {
    lact.enable = true;
    xserver = {
      enable = true;
      videoDrivers = ["amdgpu"];
      xkb = {
        layout = "it";
        variant = "";
      };
    };
    displayManager.gdm.enable = true;
    # Enable CUPS to print documents.
    printing.enable = false;
    tailscale = {
      enable = true;
      useRoutingFeatures = "both";
    };
  };

  # Configure console keymap
  console.keyMap = "it2";

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lorev = {
    isNormalUser = true;
    description = "Lorenzo Pasqui";
    shell = pkgs.zsh;
    hashedPassword = "$y$j9T$/Zd2ewjXuVjuKz3YzWA3L/$iUOruuv0a6FT1QjzY1ZhTI5OkBxX88ZHXdpAJ6.tBk4";
    extraGroups = ["networkmanager" "wheel"];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
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
    # Wayland stuff
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
