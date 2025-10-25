# Auto-generated using compose2nix v0.3.1.
{
  pkgs,
  lib,
  config,
  ...
}: let
  version = "0.33.1";
in {
  sops.secrets."dockers/dawarich/db_password" = {};

  sops.templates."dawarich.env".content = ''
    DATABASE_PASSWORD=${config.sops.placeholder."dockers/dawarich/db_password"}
    POSTGRES_PASSWORD=${config.sops.placeholder."dockers/dawarich/db_password"}
  '';

  # Runtime
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";

  # Containers
  virtualisation.oci-containers.containers."dawarich_app" = {
    image = "freikin/dawarich:${version}";
    environment = {
      "APPLICATION_HOSTS" = "localhost,homelab:3000,gps.pasqui.casa,''";
      "APPLICATION_PROTOCOL" = "http";
      "DATABASE_HOST" = "dawarich_db";
      "DATABASE_NAME" = "dawarich_development";
      "DATABASE_USERNAME" = "postgres";
      "MIN_MINUTES_SPENT_IN_CITY" = "60";
      "PROMETHEUS_EXPORTER_ENABLED" = "false";
      "PROMETHEUS_EXPORTER_HOST" = "0.0.0.0";
      "PROMETHEUS_EXPORTER_PORT" = "9394";
      "RAILS_ENV" = "development";
      "REDIS_URL" = "redis://dawarich_redis:6379";
      "SELF_HOSTED" = "true";
      "STORE_GEODATA" = "true";
      "TIME_ZONE" = "Europe/London";
    };
    environmentFiles = [
      config.sops.templates."dawarich.env".path
    ];
    volumes = [
      "gps_dawarich_db_data:/dawarich_db_data:rw"
      "gps_dawarich_public:/var/app/public:rw"
      "gps_dawarich_storage:/var/app/storage:rw"
      "gps_dawarich_watched:/var/app/tmp/imports/watched:rw"
    ];
    ports = [
      "3000:3000/tcp"
    ];
    cmd = ["bin/rails" "server" "-p" "3000" "-b" "::"];
    dependsOn = [
      "dawarich_db"
      "dawarich_redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--cpus=0.5"
      "--health-cmd=wget -qO - http://127.0.0.1:3000/api/v1/health | grep -q '\"status\"\\s*:\\s*\"ok\"'"
      "--health-interval=10s"
      "--health-retries=30"
      "--health-start-period=30s"
      "--health-timeout=10s"
      "--memory=4294967296b"
      "--network-alias=dawarich_app"
      "--network=gps_dawarich"
    ];
  };
  systemd.services."docker-dawarich_app" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "on-failure";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-gps_dawarich.service"
      "docker-volume-gps_dawarich_db_data.service"
      "docker-volume-gps_dawarich_public.service"
      "docker-volume-gps_dawarich_storage.service"
      "docker-volume-gps_dawarich_watched.service"
    ];
    requires = [
      "docker-network-gps_dawarich.service"
      "docker-volume-gps_dawarich_db_data.service"
      "docker-volume-gps_dawarich_public.service"
      "docker-volume-gps_dawarich_storage.service"
      "docker-volume-gps_dawarich_watched.service"
    ];
    partOf = [
      "docker-compose-gps-root.target"
    ];
    wantedBy = [
      "docker-compose-gps-root.target"
    ];
  };
  virtualisation.oci-containers.containers."dawarich_db" = {
    image = "postgis/postgis:17-3.5-alpine";
    environment = {
      "POSTGRES_DB" = "dawarich_development";
      "POSTGRES_USER" = "postgres";
    };
    environmentFiles = [
      config.sops.templates."dawarich.env".path
    ];
    volumes = [
      "gps_dawarich_db_data:/var/lib/postgresql/data:rw"
      "gps_dawarich_shared:/var/shared:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=pg_isready -U postgres -d dawarich_development"
      "--health-interval=10s"
      "--health-retries=5"
      "--health-start-period=30s"
      "--health-timeout=10s"
      "--network-alias=dawarich_db"
      "--network=gps_dawarich"
      "--shm-size=1073741824"
    ];
  };
  systemd.services."docker-dawarich_db" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-gps_dawarich.service"
      "docker-volume-gps_dawarich_db_data.service"
      "docker-volume-gps_dawarich_shared.service"
    ];
    requires = [
      "docker-network-gps_dawarich.service"
      "docker-volume-gps_dawarich_db_data.service"
      "docker-volume-gps_dawarich_shared.service"
    ];
    partOf = [
      "docker-compose-gps-root.target"
    ];
    wantedBy = [
      "docker-compose-gps-root.target"
    ];
  };
  virtualisation.oci-containers.containers."dawarich_redis" = {
    image = "redis:7.4-alpine";
    volumes = [
      "gps_dawarich_shared:/data:rw"
    ];
    cmd = ["redis-server"];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=[\"redis-cli\", \"--raw\", \"incr\", \"ping\"]"
      "--health-interval=10s"
      "--health-retries=5"
      "--health-start-period=30s"
      "--health-timeout=10s"
      "--network-alias=dawarich_redis"
      "--network=gps_dawarich"
    ];
  };
  systemd.services."docker-dawarich_redis" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-gps_dawarich.service"
      "docker-volume-gps_dawarich_shared.service"
    ];
    requires = [
      "docker-network-gps_dawarich.service"
      "docker-volume-gps_dawarich_shared.service"
    ];
    partOf = [
      "docker-compose-gps-root.target"
    ];
    wantedBy = [
      "docker-compose-gps-root.target"
    ];
  };
  virtualisation.oci-containers.containers."dawarich_sidekiq" = {
    image = "freikin/dawarich:${version}";
    environment = {
      "APPLICATION_HOSTS" = "homelab";
      "APPLICATION_PROTOCOL" = "http";
      "BACKGROUND_PROCESSING_CONCURRENCY" = "10";
      "DATABASE_HOST" = "dawarich_db";
      "DATABASE_NAME" = "dawarich_development";
      "DATABASE_USERNAME" = "postgres";
      "PROMETHEUS_EXPORTER_ENABLED" = "false";
      "PROMETHEUS_EXPORTER_HOST" = "dawarich_app";
      "PROMETHEUS_EXPORTER_PORT" = "9394";
      "RAILS_ENV" = "development";
      "REDIS_URL" = "redis://dawarich_redis:6379";
      "SELF_HOSTED" = "true";
      "STORE_GEODATA" = "true";
    };
    environmentFiles = [
      config.sops.templates."dawarich.env".path
    ];
    volumes = [
      "gps_dawarich_public:/var/app/public:rw"
      "gps_dawarich_storage:/var/app/storage:rw"
      "gps_dawarich_watched:/var/app/tmp/imports/watched:rw"
    ];
    cmd = ["sidekiq"];
    dependsOn = [
      "dawarich_app"
      "dawarich_db"
      "dawarich_redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=pgrep -f sidekiq"
      "--health-interval=10s"
      "--health-retries=30"
      "--health-start-period=30s"
      "--health-timeout=10s"
      "--network-alias=dawarich_sidekiq"
      "--network=gps_dawarich"
    ];
  };
  systemd.services."docker-dawarich_sidekiq" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "on-failure";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-gps_dawarich.service"
      "docker-volume-gps_dawarich_public.service"
      "docker-volume-gps_dawarich_storage.service"
      "docker-volume-gps_dawarich_watched.service"
    ];
    requires = [
      "docker-network-gps_dawarich.service"
      "docker-volume-gps_dawarich_public.service"
      "docker-volume-gps_dawarich_storage.service"
      "docker-volume-gps_dawarich_watched.service"
    ];
    partOf = [
      "docker-compose-gps-root.target"
    ];
    wantedBy = [
      "docker-compose-gps-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-gps_dawarich" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f gps_dawarich";
    };
    script = ''
      docker network inspect gps_dawarich || docker network create gps_dawarich
    '';
    partOf = ["docker-compose-gps-root.target"];
    wantedBy = ["docker-compose-gps-root.target"];
  };

  # Volumes
  systemd.services."docker-volume-gps_dawarich_db_data" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect gps_dawarich_db_data || docker volume create gps_dawarich_db_data
    '';
    partOf = ["docker-compose-gps-root.target"];
    wantedBy = ["docker-compose-gps-root.target"];
  };
  systemd.services."docker-volume-gps_dawarich_public" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect gps_dawarich_public || docker volume create gps_dawarich_public
    '';
    partOf = ["docker-compose-gps-root.target"];
    wantedBy = ["docker-compose-gps-root.target"];
  };
  systemd.services."docker-volume-gps_dawarich_shared" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect gps_dawarich_shared || docker volume create gps_dawarich_shared
    '';
    partOf = ["docker-compose-gps-root.target"];
    wantedBy = ["docker-compose-gps-root.target"];
  };
  systemd.services."docker-volume-gps_dawarich_storage" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect gps_dawarich_storage || docker volume create gps_dawarich_storage
    '';
    partOf = ["docker-compose-gps-root.target"];
    wantedBy = ["docker-compose-gps-root.target"];
  };
  systemd.services."docker-volume-gps_dawarich_watched" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect gps_dawarich_watched || docker volume create gps_dawarich_watched
    '';
    partOf = ["docker-compose-gps-root.target"];
    wantedBy = ["docker-compose-gps-root.target"];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-gps-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = ["multi-user.target"];
  };
}
