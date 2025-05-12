{
  pkgs,
  config,
  ...
}: {
  systemd.timers."backup-owncloud" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "4:00";
      Persistent = true;
    };
  };

  sops.secrets."borgbase/owncloud/remote_host" = {};
  sops.secrets."borgbase/owncloud/db_password" = {};
  systemd.services."backup-owncloud" = {
    path = with pkgs; [borgbackup curl docker unzip];
    script = ''
           #!/bin/sh
      DB_BACKUP_PATH="/home/hspasqui/archive/owncloud/owncloudDbBackup.bak"
      FILES_DIR="/home/hspasqui/archive/owncloud/files"
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
      echo removing old backup file
      rm $DB_BACKUP_PATH
      echo dumping database
      docker exec owncloud_mariadb mysqldump --single-transaction -h localhost -u owncloud --password=$DB_PASSWORD owncloud > "$DB_BACKUP_PATH"
      # stop maintenance mode
      echo stopping maintenance mode
      docker exec -u www-data owncloud_server bash -c "occ maintenance:mode --off"

      ### Append to remote Borg repository
      echo appending to remote repo
      borg create $REMOTE_HOST$REMOTE_BACKUP_PATH::{now} "$FILES_DIR" "$DB_BACKUP_PATH" || STATUS=$?
      echo pruning remote repo
      borg prune --keep-daily=2 --keep-weekly=4 --keep-monthly=3 --keep-yearly=1 $REMOTE_HOST$REMOTE_BACKUP_PATH
      echo compacting remote repo
      borg compact $REMOTE_HOST$REMOTE_BACKUP_PATH

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
      curl -s -X POST https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage -d chat_id=-1002509650347 -d text="#owncloud: $MESSAGE Tempo impiegato: $minutes min e $seconds sec"
      exit $STATUS
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    restartIfChanged = false;
  };
}
