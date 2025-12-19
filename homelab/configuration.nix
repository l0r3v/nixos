{
  pkgs,
  inputs,
  ...
}: let
  inherit (pkgs.stdenv.hostPlatform) system;
  nixvim-package = inputs.nixvim.packages.${system}.full;
in {
  imports = [
    ./hardware-configuration.nix
    ./dockers
    ./services
    ./backup-timers
    ./factorio
    ../common/nix-helpers.nix
    ../common/sops.nix
    ../common/nix-maintenance.nix
    ../common/distributed-builds.nix
    ../common/get-remote-build.nix
  ];

  hardware = {
    graphics.enable = true;
    nvidia-container-toolkit.enable = true;
    nvidia = {
      modesetting.enable = true;
      open = false;
      nvidiaSettings = false;
    };
  };
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8192;
    }
  ];
  services.xserver.videoDrivers = ["nvidia"];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "homelab"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  services.logind.settings.Login.HandleLidSwitch = "ignore";
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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "it";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "it2";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hspasqui = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "hspasqui";
    extraGroups = ["libvirtd" "networkmanager" "wheel"];
    packages = with pkgs; [];
  };

  services.getty.autologinUser = "hspasqui";

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    nixvim-package
    btop
    wget
    vim
    alejandra
    virt-manager
    xz
    usbutils
    nh
    virt-viewer
    ripgrep
    zoxide
    eza
    compose2nix
    hacompanion
    git
    gitui
    lm_sensors
    OVMF
    fzf
    borgbackup
    unzip
    keychain
    nodejs
    coreutils
    curl
    gawk
    gnused
    nodejs
    tea
    factorio-headless
  ];

  systemd.services.hacompanion = {
    enable = true;
    serviceConfig = {
      ExecStart = "${pkgs.hacompanion}/bin/hacompanion -config /srv/archive/hacompanion/hacompanion.toml";
      Restart = "on-failure";
      RestartSec = "60";
    };
  };
  virtualisation = {
    libvirtd = {
      enable = true;
    };
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };
  environment.sessionVariables = {
    EDITOR = "vim";
    TERM = "xterm-256color";
  };
  programs.bash = {
    shellAliases = {
      ll = "eza -la";
      ett = "eza --tree";
      vi = "nvim";
      vim = "nvim";
    };
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    promptInit = ''
      if [[ -r "${pkgs.zsh-powerlevel10k}/p10k-instant-prompt-finalize.zsh" ]]; then
        source "\${pkgs.zsh-powerlevel10k}/p10k-instant-prompt-finalize.zsh"
      fi
      eval "$(zoxide init --cmd cd zsh)"
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    '';
    ohMyZsh = {
      enable = true;
      plugins = ["git" "eza" "fzf" "safe-paste" "zoxide"];
    };
    shellAliases = {
      ll = "eza -l";
      lla = "eza -la";
      ett = "eza --tree";
      update = "sudo nixos-rebuild switch --flake /home/hspasqui/nixos-homelab/#";
    };
    histSize = 10000;
  };

  services.openssh = {
    enable = true;
    ports = [44];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = ["hspasqui" "gitlab"];
      X11Forwarding = true;
      PermitRootLogin = "prohibit-password";
      AllowAgentForwarding = true;
      PermitUserEnvironment = true;
    };
  };
  services.watchdogd = {
    enable = true;
  };

  networking.firewall.allowedTCPPorts = [22 8123 8080 8031 8083 2443 44 5423 6080 5901];
  networking.firewall.allowedUDPPorts = [8123 8031 6080 5901];

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    substituters = [
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    trusted-users = ["root" "@wheel"];
  };

  system.stateVersion = "24.11"; # Did you read the comment?
}
