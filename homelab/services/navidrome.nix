_: let
  port = 4533;
in {
  homelab.tunnelRoutes = {
    "music.pasqui.casa" = "http://localhost:${toString port}";
  };

  services.navidrome = {
    enable = true;
    settings = {
      MusicFolder = "/srv/archive/music";
      DataFolder = "/srv/archive/navidrome/config";
      Port = port;
    };
  };
  users.groups.music = {};

  users.users = {
    navidrome.extraGroups = ["music"];
  };
}
