{config, ...}: {
  homelab.tunnelRoutes = {
    "prowlarr.pasqui.casa" = "http://localhost:${toString config.services.prowlarr.settings.server.port}";
  };

  services.prowlarr = {
    enable = true;
    dataDir = "/srv/archive/prowlarr";
    settings = {
      server.port = 9696;
    };
  };

  systemd.tmpfiles.rules = [
    "d /srv/archive/prowlarr 0755 prowlarr prowlarr -"
  ];
}
