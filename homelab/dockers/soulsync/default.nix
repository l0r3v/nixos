{
  config,
  lib,
  ...
}: {
  virtualisation.oci-containers.containers."soulsync" = {
    image = "ghcr.io/nezreka/soulsync:latest";
    environment = {
      PUID = "900";
      PGID = "975";
    };
    ports = [
      "8008:8008/tcp" # Web UI
      "8888:8888/tcp" # Spotify OAuth
      "8889:8889/tcp" # Tidal OAuth
    ];
    volumes = [
      "/srv/archive/soulsync/config:/app/config:rw"
      "/srv/archive/soulsync/data:/app/data:rw"
      "/srv/archive/soulsync/logs:/app/logs:rw"
      "/srv/archive/music:/music:rw"
      "/srv/archive/downloads/soulseek:/downloads:rw"
      "/srv/archive/imports/music:/imports:rw"
    ];
  };

  systemd.services."docker-soulsync" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "on-failure";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = ["docker.service"];
    requires = ["docker.service"];
    wantedBy = ["multi-user.target"];
  };
}
