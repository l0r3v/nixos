{lib, pkgs, ...}: let
  caddyPort = 8085;
in {
  homelab.tunnelRoutes = {
    "notes.pasqui.casa" = "http://localhost:${toString caddyPort}";
  };

  services.caddy.virtualHosts.":${toString caddyPort}" = {
    extraConfig = ''
      root * /home/hspasqui/notes/public
      try_files {path} {path}.html {path}/index.html /Garden/index.html
      file_server
    '';
  };

  systemd.services.caddy.serviceConfig.ProtectHome = lib.mkForce false;

  # Ensure Caddy can traverse /home/hspasqui (tmpfiles runs at boot)
  systemd.tmpfiles.rules = [
    "d /home/hspasqui/notes/public 0755 hspasqui users -"
    "a /home/hspasqui - - - - o:x"
  ];
}
