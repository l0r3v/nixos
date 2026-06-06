{
  config,
  lib,
  ...
}: let
  port = 6500;
in {
  virtualisation.oci-containers.containers."rdt-client" = {
    image = "rogerfar/rdtclient:latest";
    environment = {
      PUID = "306";
      PGID = toString config.users.groups.music.gid;
      TZ = "Europe/Rome";
    };
    volumes = [
      "/srv/archive/downloads:/data/downloads:rw"
      "/srv/archive/lidarr/rdtclient:/data/db:rw"
    ];
    ports = [
      "${toString port}:6500/tcp"
    ];
    log-driver = "json-file";
    extraOptions = [
      "--log-opt=max-size=10m"
    ];
  };

  systemd.services."docker-rdt-client" = {
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
