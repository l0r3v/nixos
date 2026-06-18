_: let
  port = 4533;
in {
  homelab.tunnelRoutes = {
    "music.pasqui.casa" = "http://localhost:${toString port}";
  };

  services.navidrome = {
    enable = true;
    user = "music";
    settings = {
      MusicFolder = "/srv/archive/music";
      DataFolder = "/srv/archive/navidrome/config";
      Port = port;
    };
  };
  users.groups.music = {};
  users.users.music = {
    uid = 900;
    group = "music";
    description = "Music system user";
    isSystemUser = true;
    home = "/srv/archive/music";
    createHome = false;
  };
}
