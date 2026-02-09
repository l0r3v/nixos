{pkgs, ...}: let
  user = "lorev";
in {
  networking.firewall.trustedInterfaces = ["tailscale0"];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [47984 47989 47990 48010];
    allowedUDPPorts = [47998 47999 48000 48002 48010];
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
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
  systemd.user.services.sunshine = {
    description = "Sunshine Game Stream Server";
    wantedBy = ["graphical-session.target"];
    partOf = ["graphical-session.target"];

    serviceConfig = {
      ExecStart = "${pkgs.sunshine}/bin/sunshine";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
