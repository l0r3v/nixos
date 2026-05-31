{pkgs, ...}: let
  user = "lorev";
in {
  networking.firewall.trustedInterfaces = ["tailscale0"];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [47984 47989 47990 48010];
    allowedUDPPorts = [47998 47999 48000 48002 48010];
    extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 22 -s 192.168.1.0/16 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 22 -s 100.0.0.0/8 -j nixos-fw-accept
      iptables -A nixos-fw -p tcp --dport 22 -j nixos-fw-log-refuse
    '';
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

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    sunshine = {
      enable = true;
      capSysAdmin = true; # Necessario per la cattura KMS su Wayland
      openFirewall = true;
    };
    displayManager = {
      autoLogin.enable = true;
      autoLogin.user = user;
    };

    udev.extraRules = ''
      KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess"
    '';
  };
  systemd.services = {
    "getty@tty1".enable = false;
    "autovt@tty1".enable = false;
  };
  environment.systemPackages = [pkgs.sunshine];

  boot.kernelModules = ["uinput"];
}
