# Auto-generated using compose2nix v0.3.1.
{
  pkgs,
  lib,
config,
  ...
}:
let
  version = "10.15";
  in
{
  # Runtime
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";

  sops.secrets = {
    "dockers/owncloud/password" = {};
    "dockers/owncloud/admin_user" = {};
    "dockers/owncloud/admin_pass" = {};
    "dockers/owncloud/trusted_domain" = {};
  };
  sops.templates."owncloud-docker.env".content = ''
OWNCLOUD_ADMIN_PASS=${config.sops.placeholder."dockers/owncloud/admin_pass"}
OWNCLOUD_ADMIN_USERNAME=${config.sops.placeholder."dockers/owncloud/admin_user"}
MYSQL_PASSWORD=${config.sops.placeholder."dockers/owncloud/password"}
MYSQL_ROOT_PASSWORD=${config.sops.placeholder."dockers/owncloud/password"}
OWNCLOUD_DB_PASSWORD=${config.sops.placeholder."dockers/owncloud/password"}

OWNCLOUD_TRUSTED_DOMAINS=${config.sops.placeholder."dockers/owncloud/trusted_domain"}
OWNCLOUD_VERSION=${version}
OWNCLOUD_DOMAIN=localhost:8080
HTTP_PORT=2424
  '';
  # Containers
  virtualisation.oci-containers.containers."owncloud_mariadb" = {
    image = "mariadb:10.11";
    environment = {
      "MARIADB_AUTO_UPGRADE" = "1";
      "MYSQL_DATABASE" = "owncloud";
      "MYSQL_USER" = "owncloud";
    };
    environmentFiles = [
      config.sops.templates."owncloud-docker.env".path
    ];
    volumes = [
      "/home/hspasqui/archive/owncloud/mysql:/var/lib/mysql:rw"
    ];
    cmd = ["--max-allowed-packet=128M" "--innodb-log-file-size=64M"];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=[\"mysqladmin\", \"ping\", \"-u\", \"root\", \"--password=owncloud\"]"
      "--health-interval=10s"
      "--health-retries=5"
      "--health-timeout=5s"
      "--network-alias=mariadb"
      "--network=owncloud_default"
    ];
  };
  systemd.services."docker-owncloud_mariadb" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-owncloud_default.service"
    ];
    requires = [
      "docker-network-owncloud_default.service"
    ];
    partOf = [
      "docker-compose-owncloud-root.target"
    ];
    wantedBy = [
      "docker-compose-owncloud-root.target"
    ];
  };
  virtualisation.oci-containers.containers."owncloud_redis" = {
    image = "redis:6";
    environmentFiles = [
      config.sops.templates."owncloud-docker.env".path
    ];
    volumes = [
      "/home/hspasqui/archive/owncloud/redis:/data:rw"
    ];
    cmd = ["--databases" "1"];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=[\"redis-cli\", \"ping\"]"
      "--health-interval=10s"
      "--health-retries=5"
      "--health-timeout=5s"
      "--network-alias=redis"
      "--network=owncloud_default"
    ];
  };
  systemd.services."docker-owncloud_redis" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-owncloud_default.service"
    ];
    requires = [
      "docker-network-owncloud_default.service"
    ];
    partOf = [
      "docker-compose-owncloud-root.target"
    ];
    wantedBy = [
      "docker-compose-owncloud-root.target"
    ];
  };
  virtualisation.oci-containers.containers."owncloud_server" = {
    image = "owncloud/server:${version}";
    environment = {
      "OWNCLOUD_DB_HOST" = "mariadb";
      "OWNCLOUD_DB_NAME" = "owncloud";
      "OWNCLOUD_DB_TYPE" = "mysql";
      "OWNCLOUD_DB_USERNAME" = "owncloud";
      "OWNCLOUD_MYSQL_UTF8MB4" = "true";
      "OWNCLOUD_REDIS_ENABLED" = "true";
      "OWNCLOUD_REDIS_HOST" = "redis";
    };
    environmentFiles = [
      config.sops.templates."owncloud-docker.env".path
    ];
    volumes = [
      "/home/hspasqui/archive/owncloud/files:/mnt/data:rw"
    ];
    ports = [
      "2424:8080/tcp"
    ];
    dependsOn = [
      "owncloud_mariadb"
      "owncloud_redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=[\"/usr/bin/healthcheck\"]"
      "--health-interval=30s"
      "--health-retries=5"
      "--health-timeout=10s"
      "--network-alias=owncloud"
      "--network=owncloud_default"
    ];
  };
  systemd.services."docker-owncloud_server" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-owncloud_default.service"
    ];
    requires = [
      "docker-network-owncloud_default.service"
    ];
    partOf = [
      "docker-compose-owncloud-root.target"
    ];
    wantedBy = [
      "docker-compose-owncloud-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-owncloud_default" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f owncloud_default";
    };
    script = ''
      docker network inspect owncloud_default || docker network create owncloud_default
    '';
    partOf = ["docker-compose-owncloud-root.target"];
    wantedBy = ["docker-compose-owncloud-root.target"];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-owncloud-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = ["multi-user.target"];
  };
}

