{
  pkgs,
  config,
  ...
}: {
  sops.secrets = {
    "immich/db_password" = {};
  };

  sops.templates."immich.env".content = ''
    DB_PASSWORD=${config.sops.placeholder."immich/db_password"}
    POSTGRES_PASSWORD=${config.sops.placeholder."immich/db_password"}
  '';
  services.nginx = {
    enable = true;
    virtualHosts."immich-cors" = {
      listen = [
        {
          addr = "127.0.0.1";
          port = 2285;
        }
      ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:2283";
        extraConfig = ''
          if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Allow-Methods' 'GET, PUT, POST, DELETE, OPTIONS' always;
            add_header 'Access-Control-Allow-Headers' 'Authorization, X-Api-Key, User-Agent, Content-Type' always;
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain charset=UTF-8';
            add_header 'Content-Length' 0;
            return 204;
          }
          if ($request_method ~* '(GET|POST|DELETE)') {
            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
            add_header 'Access-Control-Allow-Headers' 'Authorization, X-Api-Key, User-Agent, Content-Type' always;
            add_header 'Access-Control-Max-Age' 1728000;
          }
        '';
      };
    };
  };
  services.immich = {
    enable = true;
    port = 2283;
    host = "0.0.0.0";
    openFirewall = true;
    mediaLocation = "/srv/archive/immich/uploads";
    secretsFile = config.sops.templates."immich.env".path;
    environment = {
      TZ = "Europe/Rome";
    };
    accelerationDevices = null;
  };
  users.users.immich.extraGroups = ["video" "render"];

  ############
  ###BACKUP###
  ############

  systemd.timers."backup-immich" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "4:00";
      Persistent = true;
    };
  };
  sops.secrets.telegram_bot_token = {};
  sops.secrets."borgbase/immich/remote_host" = {};
  systemd.services."backup-immich" = {
    path = with pkgs; [borgbackup curl util-linux postgresql];
    script = ''
        #!/bin/sh

      # Paths
      UPLOAD_LOCATION="/srv/archive/immich/uploads"
      BACKUP_PATH="/srv/archive/backup/immich"
      REMOTE_HOST="$(cat ${config.sops.secrets."borgbase/immich/remote_host".path})"
      REMOTE_BACKUP_PATH="./repo"
      export BORG_PASSCOMMAND="cat /home/hspasqui/.borg_passphrase"
      export BORG_RSH="ssh -i /home/hspasqui/.ssh/backup-ssh -o StrictHostKeyChecking=no"
      TELEGRAM_BOT_TOKEN="$(cat ${config.sops.secrets.telegram_bot_token.path})"
      STATUS=0

      #curl -s -X POST https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage -d chat_id=-1002509650347 -d text="#immich: #startedBackup"
      start_time=$(date +%s)
      # Backup Immich database
      echo stopping immich slice
      systemctl stop immich-server.service immich-machine-learning.service
      echo started immich database dump
      #docker exec -t immich_postgres pg_dumpall --clean --if-exists --username=postgres > "$UPLOAD_LOCATION"/database-backup/immich-database.sql
      runuser -u postgres -- pg_dump --clean --if-exists --username=postgres immich > "$UPLOAD_LOCATION/immich-database.sql"
      echo finished immich database dump, restarting immich service
      #docker start immich_server
      echo append to borg remote
      ### Append to remote Borg repository
      borg create $REMOTE_HOST$REMOTE_BACKUP_PATH::{now} /srv/archive/./immich/uploads --exclude "$UPLOAD_LOCATION/thumbs" --exclude "$UPLOAD_LOCATION/encoded-video" || STATUS=$?
      systemctl start immich-server.service immich-machine-learning.service
      #echo pruning remote
      #borg prune --keep-daily=3 --keep-weekly=4 --keep-monthly=6 --keep-yearly=1 $REMOTE_HOST$REMOTE_BACKUP_PATH
      #echo compacting remote
      #borg compact $REMOTE_HOST$REMOTE_BACKUP_PATH

      end_time=$(date +%s)
      duration=$((end_time -start_time))
      minutes=$(( (duration % 3600) / 60 ))
      seconds=$((duration % 60))
      MESSAGE="C'è qualcosa che no va nello script"
      if [ "$STATUS" -eq 0 ]; then
        MESSAGE="✅ Backup completato con successo"
      else
        MESSAGE="❌ Errore nel backup @Lorevocator"
      fi
      echo Status $STATUS: $MESSAGE
      curl -s -X POST https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage -d chat_id=-1002509650347 -d message_thread_id=5596 -d text="#immich: $MESSAGE Tempo impiegato: $minutes min e $seconds sec"
      exit $STATUS

    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    restartIfChanged = false;
  };
}
