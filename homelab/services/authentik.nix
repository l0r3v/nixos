{
  pkgs,
  config,
  ...
}: let
  httpPort = 9091;
in {
  homelab.tunnelRoutes = {
    "auth.pasqui.casa" = "http://localhost:${toString httpPort}";
  };

  services.authentik = {
    enable = true;

    environmentFile = config.sops.templates."authentik.env".path;

    settings = {
      # Forza la connessione tramite Unix Socket per usare l'autenticazione 'peer'
      postgresql = {
        name = "authentik";
        user = "authentik";
        host = "/run/postgresql";
      };

      listen = {
        http = ["127.0.0.1:${toString httpPort}"];
        https = ["127.0.0.1:9443"];
      };

      email = {
        port = 587;
        use_tls = true;
        use_ssl = false;
        timeout = 10;
      };

      disable_startup_analytics = true;
      disable_update_check = false;

      avatars = "initials";

      log_level = "info";

      error_reporting = {
        enabled = false;
        send_pii = false;
      };
    };
  };

  sops.secrets = {
    "authentik/secret_key" = {};
    "authentik/email_host" = {};
    "authentik/email_password" = {};
    "authentik/email_from" = {};
    "authentik/email_username" = {};
  };

  sops.templates."authentik.env" = {
    content = ''
      AUTHENTIK_SECRET_KEY=${config.sops.placeholder."authentik/secret_key"}
      AUTHENTIK_EMAIL__HOST=${config.sops.placeholder."authentik/email_host"}
      AUTHENTIK_EMAIL__PASSWORD=${config.sops.placeholder."authentik/email_password"}
      AUTHENTIK_EMAIL__FROM=${config.sops.placeholder."authentik/email_from"}
      AUTHENTIK_EMAIL__USERNAME=${config.sops.placeholder."authentik/email_username"}
      AUTHENTIK_EMAIL__PORT="587"
      AUTHENTIK_EMAIL__TIMEOUT="10"
      AUTHENTIK_EMAIL__USE_SSL="false"
      AUTHENTIK_EMAIL__USE_TLS="true"
    '';
    restartUnits = ["authentik-server.service" "authentik-worker.service"];
  };

  services.postgresqlBackup = {
    enable = true;
    databases = ["authentik"];
    startAt = "*-*-* 03:00:00";
    location = "/var/backup/postgresql";
    compression = "zstd";
  };

  ############
  ###BACKUP###
  ############

  systemd.timers."backup-authentik" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "4:00";
      Persistent = true;
    };
  };

  sops.secrets.telegram_bot_token = {};
  sops.secrets."borgbase/authentik/remote_host" = {};
  systemd.services."backup-authentik" = {
    path = with pkgs; [borgbackup curl util-linux postgresql];
    script = ''
        #!/bin/sh

      # Paths
      BACKUP_PATH="/srv/archive/backup/authentik"
      REMOTE_HOST="$(cat ${config.sops.secrets."borgbase/authentik/remote_host".path})"
      REMOTE_BACKUP_PATH="./repo"
      export BORG_PASSCOMMAND="cat /home/hspasqui/.borg_passphrase"
      export BORG_RSH="ssh -i /home/hspasqui/.ssh/backup-ssh -o StrictHostKeyChecking=no"
      TELEGRAM_BOT_TOKEN="$(cat ${config.sops.secrets.telegram_bot_token.path})"
      STATUS=0

      #curl -s -X POST https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage -d chat_id=-1002509650347 -d text="#authentik: #startedBackup"
      start_time=$(date +%s)
      # Backup authentik database
      echo stopping authentik slice
      systemctl stop authentik.service authentik-migrate.service authentik-worker.service
      echo started authentik database dump
      runuser -u postgres -- pg_dump --clean --if-exists --username=postgres authentik > "$BACKUP_PATH/authentik-database.sql"
      echo finished authentik database dump, restarting authentik service
      systemctl start authentik.service authentik-migrate.service authentik-worker.service
      echo append to borg remote
      ### Append to remote Borg repository
      borg create --stats --compression zstd $REMOTE_HOST$REMOTE_BACKUP_PATH::{now} "$BACKUP_PATH" /var/lib/authentik/media || STATUS=$?

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
      curl -s -X POST https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage -d chat_id=-1002509650347 -d message_thread_id=5596 -d text="#authentik: $MESSAGE Tempo impiegato: $minutes min e $seconds sec"
      exit $STATUS

    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    restartIfChanged = false;
  };
}
