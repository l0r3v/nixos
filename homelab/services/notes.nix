{
  lib,
  pkgs,
  ...
}: let
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

  # Ensure Caddy can traverse /home/hspasqui (runs after every deploy)
  systemd.services.fix-caddy-home = {
    description = "Fix /home/hspasqui permission for Caddy";
    after = ["nixos-activation.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.coreutils}/bin/chmod o+x /home/hspasqui";
      RemainAfterExit = true;
    };
  };
}
