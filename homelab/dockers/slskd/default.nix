{lib, ...}: {
  virtualisation.oci-containers.containers."slskd" = {
    image = "slskd/slskd:latest";
    environment = {
      SLSKD_SHARED_DIR = "/music";
      SLSKD_DIRECTORIES_DOWNLOADS = "/downloads";
      SLSKD_DIRECTORIES_INCOMPLETE = "/downloads/incomplete";
      SLSKD_REMOTE_CONFIGURATION = "true";
      PUID = "900";
      PGID = "975";
    };
    ports = [
      "5030:5030/tcp"
      "5031:5031/tcp"
      "5031:5031/udp"
      "50300:50300/tcp"
    ];
    volumes = [
      "/srv/archive/slskd/config:/app:rw"
      "/srv/archive/music:/music:rw"
      "/srv/archive/downloads/soulseek:/downloads:rw"
    ];
  };
  systemd.services."docker-slskd" = {
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
