{config, ...}: {
  homelab.tunnelRoutes = {
    "lidarr.pasqui.casa" = "http://localhost:${toString config.services.lidarr.settings.server.port}";
  };

  services.lidarr = {
    enable = true;
    dataDir = "/srv/archive/lidarr";
    group = "music";
    settings = {
      server.port = 8686;
    };
  };

  systemd.tmpfiles.rules = [
    "d /srv/archive/music 2775 root music -"
    "d /srv/archive/downloads 2775 root music -"
    "d /srv/archive/lidarr 0755 lidarr music -"
  ];

  users.users.lidarr.extraGroups = ["music"];
}
