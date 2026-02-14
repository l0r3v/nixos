{
  services.gonic = {
    enable = true;
    settings = {
      "music-path" = "/srv/archive/music";
      "podcast-path" = "/srv/archive/gonic/podcasts";
      "playlists-path" = "/srv/archive/gonic/playlists";
      "data-path" = "/srv/archive/gonic";
    };
  };

  users.groups.gonic = {};
  users.groups.music = {};

  users.users.gonic = {
    isSystemUser = true;
    group = "gonic";
    extraGroups = ["music"];
  };
  systemd.services.gonic.serviceConfig.ReadWritePaths = [
    "/srv/archive/gonic"
  ];
}
