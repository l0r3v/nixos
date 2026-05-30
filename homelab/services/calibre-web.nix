{config, ...}: let
  port = 8083;
in {
  homelab.tunnelRoutes = {
    "books.pasqui.casa" = "http://localhost:${toString port}";
  };

  services.calibre-web = {
    enable = true;
    listen = {
      ip = "127.0.0.1";
      port = port;
    };
    dataDir = "/srv/archive/calibre-web/data";
    options = {
      calibreLibrary = "/srv/archive/calibre-web/data";
      enableBookConversion = true;
      enableBookUploading = true;
    };
  };

  systemd.tmpfiles.rules = [
    "d /srv/archive/calibre-web/data 0750 calibre-web calibre-web -"
  ];
}
