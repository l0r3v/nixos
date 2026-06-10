{config, ...}: {
  homelab.tunnelRoutes = {
    "readarr.pasqui.casa" = "http://localhost:${toString config.services.readarr.settings.server.port}";
  };

  services.readarr = {
    enable = true;
    dataDir = "/srv/archive/readarr";
    group = "readarr";
    openFirewall = false;
    settings = {
      server.port = 8787;
    };
  };

  systemd.tmpfiles.rules = [
    "d /srv/archive/readarr 0700 readarr readarr -"
    "d /srv/archive/books 2775 root readarr -"
    "d /srv/archive/downloads/books 2775 root readarr -"
  ];
}
