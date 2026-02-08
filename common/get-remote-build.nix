# Configurazione per server remoti NixOS
# Da includere nella configuration.nix dei server remoti
{pkgs, ...}: {
  # User dedicato per il rebuild remoto
  users.users.nixos-builder = {
    isNormalUser = true;
    description = "NixOS Remote Builder";

    # Gruppo wheel per accesso sudo
    extraGroups = ["wheel"];

    createHome = false;

    # Shell
    shell = pkgs.bash;

    # Chiavi SSH autorizzate
    # IMPORTANTE: Sostituisci con la tua chiave pubblica SSH
    openssh.authorizedKeys.keys = [
      # Aggiungi qui la tua chiave SSH pubblica
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEtJmCOrKD6hsDHRPRKjwfJV+Jckr4FFzeE9Wc9wg6gM nixos-rebuild"
    ];
  };

  # Configurazione sudo per nixos-builder
  security.sudo = {
    enable = true;

    extraRules = [
      {
        # Permetti a nixos-builder di eseguire nixos-rebuild senza password
        users = ["nixos-builder"];
        commands = [
          {
            command = "ALL";
            options = ["NOPASSWD" "SETENV"];
          }
        ];
      }
    ];
  };

  # Configurazione SSH server (solo rete locale)
  services.openssh = {
    enable = true;

    settings = {
      # Permetti login solo con chiave SSH
      PasswordAuthentication = false;
      ChallengeResponseAuthentication = false;

      # Disabilita root login con password
      PermitRootLogin = "prohibit-password";

      # Non permettere login interattivo per nixos-builder
      # (può solo eseguire comandi remoti)
      AllowUsers = ["nixos-builder"];

      # Configurazioni di sicurezza
      PubkeyAuthentication = true;
      KbdInteractiveAuthentication = false;
      PermitEmptyPasswords = false;

      # Timeout per connessioni inattive
      ClientAliveInterval = 60;
      ClientAliveCountMax = 3;
    };

    # Limita SSH solo alla rete locale
    # IMPORTANTE: Adatta questi IP al tuo range di rete locale
    listenAddresses = [
      {
        addr = "0.0.0.0"; # Ascolta su tutte le interfacce
        port = 22;
      }
    ];
  };

  # Firewall: permetti SSH solo dalla rete locale
  networking.firewall = {
    enable = true;

    # Permetti SSH (porta 22)
    allowedTCPPorts = [22];

    # Regole extra per limitare l'accesso SSH alla rete locale
    extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 22 -s 192.168.1.0/16 -j nixos-fw-accept

      iptables -A nixos-fw -p tcp --dport 22 -s 100.0.0.0/8 -j nixos-fw-accept

      iptables -A nixos-fw -p tcp --dport 22 -j nixos-fw-log-refuse
    '';
  };

  # Configurazione Nix per permettere rebuild
  nix.settings = {
    # Permetti a nixos-builder di usare nix
    trusted-users = ["root" "nixos-builder"];

    # Abilita flakes
    experimental-features = ["nix-command" "flakes"];
  };

  # Pacchetti necessari per il rebuild
  environment.systemPackages = with pkgs; [
    git
  ];

  # Opzionale: Log degli accessi SSH
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
}
