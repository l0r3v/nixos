{
  services.gonic = {
    enable = true;
    settings = {
      "music-path" = "/srv/archive/music";
      "podcast-path" = "/var/lib/gonic/podcasts";
      "playlists-path" = "/var/lib/gonic/playlists";
      "data-path" = "/var/lib/gonic";
      "port" = 8080;
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
    "/var/lib/gonic"
  ];
}
