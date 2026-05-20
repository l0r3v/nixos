{
  pkgs,
  config,
  ...
}: {
  sops = {
    secrets = {
      "forgejo/db_pass" = {
        owner = "forgejo";
      };
      "borgbase/forgejo/remote_host" = {};
      "borgbase/passphrase" = {};
      "borgbase/ssh_key" = {};
      "telegram_bot_token" = {};
    };
  };
  services.forgejo = {
    enable = true;
    package = pkgs.forgejo;
    stateDir = "/srv/archive/forgejo";
    database = {
      type = "postgres";
      user = "forgejo";
      name = "forgejo";
      passwordFile = config.sops.secrets."forgejo/db_pass".path;
    };
    settings.server.HTTP_PORT = 3001;
  };

  systemd.timers."backup-forgejo" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "4:00";
      Persistent = true;
    };
  };

  systemd.services."backup-forgejo" = {
    path = with pkgs; [borgbackup curl unzip sudo];

    script = ''
      #!/bin/sh
      set -eu

      LOCAL_DIR="/srv/archive/backup/forgejo"
      TMP_ZIP="/tmp/forgejo-dump.zip"

      export BORG_PASSCOMMAND="cat ${config.sops.secrets."borgbase/passphrase".path}"
      export BORG_RSH="ssh -i ${config.sops.secrets."borgbase/ssh_key".path} -o StrictHostKeyChecking=no"

      REMOTE_HOST="$(cat ${config.sops.secrets."borgbase/forgejo/remote_host".path})"
      REMOTE_BACKUP_PATH="./repo"
      TELEGRAM_BOT_TOKEN="$(cat ${config.sops.secrets.telegram_bot_token.path})"
      STATUS=0

      start_time=$(date +%s)
      echo "Inizio backup di Forgejo..."

      rm -rf "$LOCAL_DIR"
      mkdir -p "$LOCAL_DIR"

      sudo -u forgejo ${config.services.forgejo.package}/bin/forgejo dump \
        -c ${config.services.forgejo.stateDir}/custom/conf/app.ini \
        -f "$TMP_ZIP"

      if [ ! -f "$TMP_ZIP" ]; then
          echo "❌ Nessun dump zip generato!"
          exit 1
      fi

      echo "Estraendo l'archivio ZIP..."
      unzip -q -o "$TMP_ZIP" -d "$LOCAL_DIR"

      echo "Rimuovendo lo ZIP temporaneo..."
      rm -f "$TMP_ZIP"

      echo "Sincronizzando con Borgbase..."
      borg create $REMOTE_HOST$REMOTE_BACKUP_PATH::{now} "$LOCAL_DIR/" || STATUS=$?

      end_time=$(date +%s)
      duration=$((end_time - start_time))
      minutes=$(( (duration % 3600) / 60 ))
      seconds=$((duration % 60))

      MESSAGE="C'è qualcosa che non va nello script"
      if [ "$STATUS" -eq 0 ]; then
        MESSAGE="✅ Backup di Forgejo completato con successo"
      else
        MESSAGE="❌ Errore nel backup di Forgejo @Lorevocator"
      fi

      echo "Status $STATUS: $MESSAGE"
      curl -s -X POST https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage \
        -d chat_id=-1002509650347 \
        -d text="#forgejo: $MESSAGE. Tempo impiegato: $minutes min e $seconds sec"

      exit $STATUS
    '';

    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    restartIfChanged = false;
  };
}
