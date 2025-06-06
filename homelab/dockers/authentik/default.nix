# Auto-generated using compose2nix v0.3.1.
{
  pkgs,
  lib,
  config,
  ...
}: let
  version = "2025.6.0";
in {
  # Runtime
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";

  sops.secrets = {
    "dockers/authentik/pg_pass" = {};
    "dockers/authentik/secret_key" = {};
    "dockers/authentik/email_host" = {};
    "dockers/authentik/email_password" = {};
    "dockers/authentik/email_from" = {};
    "dockers/authentik/email_username" = {};
  };
  sops.templates."authentik-docker.env".content = ''
    PG_PASS=${config.sops.placeholder."dockers/authentik/pg_pass"}
    AUTHENTIK_SECRET_KEY=${config.sops.placeholder."dockers/authentik/secret_key"}
    AUTHENTIK_EMAIL__HOST=${config.sops.placeholder."dockers/authentik/email_host"}
    AUTHENTIK_EMAIL__PASSWORD=${config.sops.placeholder."dockers/authentik/email_password"}
    AUTHENTIK_EMAIL__FROM=${config.sops.placeholder."dockers/authentik/email_from"}
    AUTHENTIK_EMAIL__USERNAME=${config.sops.placeholder."dockers/authentik/email_username"}
    AUTHENTIK_EMAIL__PORT="587"
    AUTHENTIK_EMAIL__TIMEOUT="10"
    AUTHENTIK_EMAIL__USE_SSL="false"
    AUTHENTIK_EMAIL__USE_TLS="true"
  '';
  # Containers
  virtualisation.oci-containers.containers."auth-postgresql" = {
    image = "docker.io/library/postgres:16-alpine";
    environment = {
      "POSTGRES_DB" = "authentik";
      "POSTGRES_PASSWORD" = "\${PG_PASS}";
      "POSTGRES_USER" = "authentik";
    };
    environmentFiles = [
      config.sops.templates."authentik-docker.env".path
    ];
    volumes = [
      "auth_database:/var/lib/postgresql/data:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=pg_isready -d \${POSTGRES_DB} -U \${POSTGRES_USER}"
      "--health-interval=30s"
      "--health-retries=5"
      "--health-start-period=20s"
      "--health-timeout=5s"
      "--network-alias=postgresql"
      "--network=auth_default"
    ];
  };
  systemd.services."docker-auth-postgresql" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-auth_default.service"
      "docker-volume-auth_database.service"
    ];
    requires = [
      "docker-network-auth_default.service"
      "docker-volume-auth_database.service"
    ];
    partOf = [
      "docker-compose-auth-root.target"
    ];
    wantedBy = [
      "docker-compose-auth-root.target"
    ];
  };
  virtualisation.oci-containers.containers."auth-redis" = {
    image = "docker.io/library/redis:alpine";
    volumes = [
      "auth_redis:/data:rw"
    ];
    cmd = ["--save" "60" "1" "--loglevel" "warning"];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=redis-cli ping | grep PONG"
      "--health-interval=30s"
      "--health-retries=5"
      "--health-start-period=20s"
      "--health-timeout=3s"
      "--network-alias=redis"
      "--network=auth_default"
    ];
  };
  systemd.services."docker-auth-redis" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-auth_default.service"
      "docker-volume-auth_redis.service"
    ];
    requires = [
      "docker-network-auth_default.service"
      "docker-volume-auth_redis.service"
    ];
    partOf = [
      "docker-compose-auth-root.target"
    ];
    wantedBy = [
      "docker-compose-auth-root.target"
    ];
  };
  virtualisation.oci-containers.containers."auth-server" = {
    image = "ghcr.io/goauthentik/server:${version}";
    environmentFiles = [
      config.sops.templates."authentik-docker.env".path
    ];
    environment = {
      "AUTHENTIK_POSTGRESQL__HOST" = "postgresql";
      "AUTHENTIK_POSTGRESQL__NAME" = "authentik";
      "AUTHENTIK_POSTGRESQL__PASSWORD" = "\${PG_PASS}";
      "AUTHENTIK_POSTGRESQL__USER" = "authentik";
      "AUTHENTIK_REDIS__HOST" = "redis";
    };
    volumes = [
      "/srv/archive/authentik/custom-templates:/templates:rw"
      "/srv/archive/authentik/media:/media:rw"
    ];
    ports = [
      "9091:9000/tcp"
      "9443:9443/tcp"
    ];
    cmd = ["server"];
    dependsOn = [
      "auth-postgresql"
      "auth-redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=server"
      "--network=auth_default"
    ];
  };
  systemd.services."docker-auth-server" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-auth_default.service"
    ];
    requires = [
      "docker-network-auth_default.service"
    ];
    partOf = [
      "docker-compose-auth-root.target"
    ];
    wantedBy = [
      "docker-compose-auth-root.target"
    ];
  };
  virtualisation.oci-containers.containers."auth-worker" = {
    image = "ghcr.io/goauthentik/server:${version}";
    environmentFiles = [
      config.sops.templates."authentik-docker.env".path
    ];
    environment = {
      "AUTHENTIK_POSTGRESQL__HOST" = "postgresql";
      "AUTHENTIK_POSTGRESQL__NAME" = "authentik";
      "AUTHENTIK_POSTGRESQL__PASSWORD" = "\${PG_PASS}";
      "AUTHENTIK_POSTGRESQL__USER" = "authentik";
      "AUTHENTIK_REDIS__HOST" = "redis";
    };
    volumes = [
      "/srv/archive/authentik/certs:/certs:rw"
      "/srv/archive/authentik/custom-templates:/templates:rw"
      "/srv/archive/authentik/media:/media:rw"
      "/var/run/docker.sock:/var/run/docker.sock:rw"
    ];
    cmd = ["worker"];
    dependsOn = [
      "auth-postgresql"
      "auth-redis"
    ];
    user = "root";
    log-driver = "journald";
    extraOptions = [
      "--network-alias=worker"
      "--network=auth_default"
    ];
  };
  systemd.services."docker-auth-worker" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-auth_default.service"
    ];
    requires = [
      "docker-network-auth_default.service"
    ];
    partOf = [
      "docker-compose-auth-root.target"
    ];
    wantedBy = [
      "docker-compose-auth-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-auth_default" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f auth_default";
    };
    script = ''
      docker network inspect auth_default || docker network create auth_default
    '';
    partOf = ["docker-compose-auth-root.target"];
    wantedBy = ["docker-compose-auth-root.target"];
  };

  # Volumes
  systemd.services."docker-volume-auth_database" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect auth_database || docker volume create auth_database --driver=local
    '';
    partOf = ["docker-compose-auth-root.target"];
    wantedBy = ["docker-compose-auth-root.target"];
  };
  systemd.services."docker-volume-auth_redis" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect auth_redis || docker volume create auth_redis --driver=local
    '';
    partOf = ["docker-compose-auth-root.target"];
    wantedBy = ["docker-compose-auth-root.target"];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-auth-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = ["multi-user.target"];
  };
}
