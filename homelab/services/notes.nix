{lib, pkgs, ...}: let
  caddyPort = 8085;
in {
  homelab.tunnelRoutes = {
    "notes.pasqui.casa" = "http://localhost:${toString caddyPort}";
  };

  services.caddy.virtualHosts.":${toString caddyPort}" = {
    extraConfig = ''
      root * /home/hspasqui/notes/public
      file_server
    '';
  };

  systemd.services.caddy.serviceConfig.ProtectHome = lib.mkForce false;

  systemd.tmpfiles.rules = [
    "d /home/hspasqui/notes/public 0755 hspasqui users -"
  ];

  # Caddy needs to traverse /home/hspasqui to serve files
  systemd.services.caddy.serviceConfig.ExecStartPre = [
    "+${pkgs.coreutils}/bin/chmod o+x /home/hspasqui"
  ];
}
