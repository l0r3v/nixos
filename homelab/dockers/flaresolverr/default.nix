{
  config,
  lib,
  ...
}: {
  virtualisation.oci-containers.containers."flaresolverr" = {
    image = "flaresolverr/flaresolverr:latest";
    environment = {
      LOG_LEVEL = "info";
    };
    ports = [
      "8191:8191/tcp"
    ];
    log-driver = "json-file";
    extraOptions = [
      "--log-opt=max-size=10m"
    ];
  };

  systemd.services."docker-flaresolverr" = {
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
