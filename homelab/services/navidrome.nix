{...}: {
  services.navidrome = {
    enable = true;
    settings = {
      MusicFolder = "/srv/archive/navidrome/music";
      DataFolder = "/srv/archive/navidrome/config";
    };
  };
}
