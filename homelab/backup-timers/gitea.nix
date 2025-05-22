{
  pkgs,
  config,
  ...
}: {
  systemd.timers."backup-gitea" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "4:00";
      Persistent = true;
    };
  };

  sops.secrets."borgbase/gitea/remote_host" = {};
  systemd.services."backup-gitea" = {
    path = with pkgs; [borgbackup curl docker unzip];
    script = ''
           #!/bin/sh
      CONTAINER_NAME=gitea
      REMOTE_DIR=/tmp
      PATTERN=gitea-dump-*.zip
      LOCAL_DIR=/srv/archive/backup/gitea/
      export BORG_PASSCOMMAND="cat /home/hspasqui/.borg_passphrase"
      export BORG_RSH="ssh -i /home/hspasqui/.ssh/backup-ssh -o StrictHostKeyChecking=no"
      # Paths
      REMOTE_HOST="$(cat ${config.sops.secrets."borgbase/gitea/remote_host".path})"
      REMOTE_BACKUP_PATH="./repo"
      TELEGRAM_BOT_TOKEN="$(cat ${config.sops.secrets.telegram_bot_token.path})"
      STATUS=0

      #curl -s -X POST https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage -d chat_id=-1002509650347 -d text="#gitea: #startedBackup"

      start_time=$(date +%s)
      echo dumping gitea
      # Backup Gitea
      docker exec -u git  -w "/tmp" $(docker ps -qf 'name=^gitea$') bash -c '/usr/local/bin/gitea dump -c /data/gitea/conf/app.ini'
      # Trova il file nel container
      echo finding gitea file in container
      FILE_PATH=$(docker exec "$CONTAINER_NAME" sh -c "ls $REMOTE_DIR/$PATTERN 2>/dev/null | sort | tail -n 1")

      if [ -z "$FILE_PATH" ]; then
          echo "❌ Nessun file trovato con pattern $PATTERN"
          exit 1
      fi

      # Estrai solo il nome file da path completo
      FILENAME=$(basename "$FILE_PATH")

      #elimina cartella backup completamente (tanto dovrebbe venire sovrascritta)
      rm -rf $LOCAL_DIR/*
      # Copia il file dal container al tuo host
      echo copying gitea file from container
      docker cp "$CONTAINER_NAME:$FILE_PATH" "$LOCAL_DIR/gitea-dump.zip"
      echo "✅ File copiato: $FILENAME → $LOCAL_DIR"

      # Elimina il file dal container
      docker exec "$CONTAINER_NAME" rm "$FILE_PATH"
      if [ $? -eq 0 ]; then
          echo "✅ File copiato e rimosso: $FILENAME"
      else
          echo "⚠️  File copiato, ma non rimosso: $FILENAME"
      fi

      echo "unzipping"
      unzip  -o "$LOCAL_DIR/gitea-dump.zip" -d $LOCAL_DIR
      echo "deleting zip"
      rm -f "$LOCAL_DIR/gitea-dump.zip"
      ### Append to remote Borg repository
      echo appending to remote repo
      borg create $REMOTE_HOST$REMOTE_BACKUP_PATH::{now} /srv/archive/backup/./gitea/ || STATUS=$?
      # echo pruning remote repo
      # borg prune --keep-daily=7 --keep-weekly=4 --keep-monthly=4 --keep-yearly=2 $REMOTE_HOST$REMOTE_BACKUP_PATH
      # echo compacting remote repo
      # borg compact $REMOTE_HOST$REMOTE_BACKUP_PATH

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
      curl -s -X POST https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage -d chat_id=-1002509650347 -d text="#gitea: $MESSAGE Tempo impiegato: $minutes min e $seconds sec"
      exit $STATUS
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    restartIfChanged = false;
  };
}
