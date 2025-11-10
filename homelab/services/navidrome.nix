{...}: {
  services.navidrome = {
    enable = true;
    settings = {
      MusicFolder = "/srv/archive/music";
      DataFolder = "/srv/archive/navidrome/config";
    };
  };
  users.groups.music = {};

  users.users = {
    navidrome.extraGroups = ["music"];
  };
}
