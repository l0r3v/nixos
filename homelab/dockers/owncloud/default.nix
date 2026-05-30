# Auto-generated using compose2nix v0.3.1.
{
  pkgs,
  lib,
  config,
  ...
}: let
  version = "10.15.3";
  port = 2424;
in {
  homelab.tunnelRoutes = {
    "files.pasqui.casa" = "http://localhost:${toString port}";
  };

  # Runtime
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";

  sops = {
    secrets = {
      "dockers/owncloud/password" = {};
      "dockers/owncloud/admin_user" = {};
      "dockers/owncloud/admin_pass" = {};
      "dockers/owncloud/trusted_domain" = {};
    };
    templates."owncloud-docker.env".content = ''
      OWNCLOUD_ADMIN_PASS=${config.sops.placeholder."dockers/owncloud/admin_pass"}
      OWNCLOUD_ADMIN_USERNAME=${config.sops.placeholder."dockers/owncloud/admin_user"}
      MYSQL_PASSWORD=${config.sops.placeholder."dockers/owncloud/password"}
      MYSQL_ROOT_PASSWORD=${config.sops.placeholder."dockers/owncloud/password"}
      OWNCLOUD_DB_PASSWORD=${config.sops.placeholder."dockers/owncloud/password"}

      OWNCLOUD_TRUSTED_DOMAINS=${config.sops.placeholder."dockers/owncloud/trusted_domain"}
      OWNCLOUD_VERSION=${version}
      OWNCLOUD_DOMAIN=localhost:8080
      HTTP_PORT=${toString port}
    '';
  };
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
      "/srv/archive/owncloud/mysql:/var/lib/mysql:rw"
    ];
    cmd = ["--max-allowed-packet=128M" "--innodb-log-file-size=64M"];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=mysqladmin ping -u root --password=owncloud"
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
      "/srv/archive/owncloud/redis:/data:rw"
    ];
    cmd = ["--databases" "1"];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=redis-cli ping"
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
      "/srv/archive/owncloud/files:/mnt/data:rw"
    ];
    ports = [
      "${toString port}:8080/tcp"
    ];
    dependsOn = [
      "owncloud_mariadb"
      "owncloud_redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=\"healthcheck\""
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

  ############
  ###BACKUP###
  ############

  systemd.timers."backup-owncloud" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "4:00";
      Persistent = true;
    };
  };

  sops.secrets.telegram_bot_token = {};
  sops.secrets."borgbase/owncloud/remote_host" = {};
  sops.secrets."borgbase/owncloud/db_password" = {};
  systemd.services."backup-owncloud" = {
    path = with pkgs; [borgbackup curl docker unzip];
    script = ''
           #!/bin/sh
      DB_BACKUP_PATH="/srv/archive/owncloud/owncloudDbBackup.bak"
      FILES_DIR="/srv/archive/owncloud/files"
      export BORG_PASSCOMMAND="cat /home/hspasqui/.borg_passphrase"
      export BORG_RSH="ssh -i /home/hspasqui/.ssh/backup-ssh -o StrictHostKeyChecking=no"
      # Paths
      REMOTE_HOST="$(cat ${config.sops.secrets."borgbase/owncloud/remote_host".path})"
      DB_PASSWORD="$(cat ${config.sops.secrets."borgbase/owncloud/db_password".path})"
      REMOTE_BACKUP_PATH="./repo"
      STATUS=0
      TELEGRAM_BOT_TOKEN="$(cat ${config.sops.secrets.telegram_bot_token.path})"

      #curl -s -X POST https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage -d chat_id=-1002509650347 -d text="#owncloud: #startedBackup"

      start_time=$(date +%s)
      ### Backup owncloud
      echo starting maintenance mode
      docker exec -u www-data owncloud_server bash -c "occ maintenance:mode --on"
      if [ -f $DB_BACKUP_PATH ]; then
        echo removing old backup file
        rm $DB_BACKUP_PATH
      fi
      echo dumping database
      docker exec owncloud_mariadb mysqldump --single-transaction -h localhost -u owncloud --password=$DB_PASSWORD owncloud > "$DB_BACKUP_PATH"
      # stop maintenance mode
      echo stopping maintenance mode
      docker exec -u www-data owncloud_server bash -c "occ maintenance:mode --off"

      ### Append to remote Borg repository
      echo appending to remote repo
      borg create $REMOTE_HOST$REMOTE_BACKUP_PATH::{now} /srv/archive/./owncloud/ --exclude "/srv/archive/owncloud/redis" --exclude "/srv/archive/owncloud/mysql" || STATUS=$?
      #echo pruning remote repo
      #borg prune --keep-daily=2 --keep-weekly=4 --keep-monthly=3 --keep-yearly=1 $REMOTE_HOST$REMOTE_BACKUP_PATH
      #echo compacting remote repo
      #borg compact $REMOTE_HOST$REMOTE_BACKUP_PATH

      end_time=$(date +%s)
      duration=$((end_time -start_time))
      minutes=$(( (duration % 3600) / 60 ))
      seconds=$((duration % 60))

      MESSAGE="C'è qualcosa che non va nello script"
      if [ "$STATUS" -eq 0 ]; then
        MESSAGE="✅ Backup completato con successo"
      else
        MESSAGE="❌ Errore nel backup @Lorevocator"
      fi
      echo status $STATUS: $MESSAGE
      curl -s -X POST https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage -d chat_id=-1002509650347 -d message_thread_id=5596 -d text="#owncloud: $MESSAGE Tempo impiegato: $minutes min e $seconds sec"
      exit $STATUS
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    restartIfChanged = false;
  };
}
