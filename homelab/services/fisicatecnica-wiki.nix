{lib, pkgs, ...}: let
  caddyPort = 1313;
in {
  homelab.tunnelRoutes = {
    "wiki.pasqui.casa" = "http://localhost:${toString caddyPort}";
  };

  services.caddy.virtualHosts.":${toString caddyPort}" = {
    extraConfig = ''
      root * /home/hspasqui/www/fisicatecnica
      file_server
    '';
  };

  systemd.services.caddy.serviceConfig.ProtectHome = lib.mkForce false;

  systemd.tmpfiles.rules = [
    "d /home/hspasqui/www/fisicatecnica 0755 hspasqui users -"
  ];

  # Caddy needs to traverse /home/hspasqui to serve files
  # '+' prefix runs ExecStartPre as root even though User=caddy
  systemd.services.caddy.serviceConfig.ExecStartPre = [
    "+${pkgs.coreutils}/bin/chmod o+x /home/hspasqui"
  ];
}
