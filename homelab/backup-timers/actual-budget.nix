{
  pkgs,
  config,
  ...
}: {
  systemd.timers."backup-actual" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "4:00";
      Persistent = true;
    };
  };

  sops.secrets."borgbase/actual/remote_host" = {};
  sops.secrets."borgbase/actual/password" = {};
  sops.secrets."borgbase/actual/url" = {};
  sops.secrets."borgbase/actual/sync_id" = {};
  systemd.services."backup-actual" = {
    path = with pkgs; [borgbackup curl jq];
    script = ''
      #!/bin/sh
      LOCAL_DIR=/srv/archive/backup/actual
      export BORG_PASSCOMMAND="cat /home/hspasqui/.borg_passphrase"
      export BORG_RSH="ssh -i /home/hspasqui/.ssh/backup-ssh -o StrictHostKeyChecking=no"
      # Paths
      REMOTE_HOST="$(cat ${config.sops.secrets."borgbase/actual/remote_host".path})" #"
      REMOTE_BACKUP_PATH="./repo"
      TELEGRAM_BOT_TOKEN="$(cat ${config.sops.secrets.telegram_bot_token.path})" #"
      STATUS=0
      BACKUP_ZIP="actual-budget-backup.zip"
      ACTUAL_BUDGET_PASSWORD="$(cat ${config.sops.secrets."borgbase/actual/password".path})"#"
      ACTUAL_BUDGET_URL="$(cat ${config.sops.secrets."borgbase/actual/url".path})" #"
      ACTUAL_BUDGET_SYNC_ID="$(cat ${config.sops.secrets."borgbase/actual/sync_id".path})" #"


      start_time=$(date +%s)

      (printf '%s\0%s\0' "loginMethod" "password" && printf '%s\0%s\0' "password" "$ACTUAL_BUDGET_PASSWORD") | jq -Rs 'split("\u0000") | . as $a
                  | reduce range(0; 2) as $i
                  ({}; . + {($a[2*$i]): ($a[2*$i + 1])})' > /tmp/login.json

      TOKEN="$(curl -s --location "$ACTUAL_BUDGET_URL/account/login" --header 'Content-Type: application/json' --data @/tmp/login.json  | jq --raw-output '.data.token')"

      rm /tmp/login.json

      FILE_ID=$(curl -s --location "$ACTUAL_BUDGET_URL/sync/list-user-files" \--header "X-ACTUAL-TOKEN: $TOKEN" | jq --raw-output ".data[] | select( [ .groupId | match(\"$ACTUAL_BUDGET_SYNC_ID\") ] | any) | .fileId")

      rm -rf $LOCAL_DIR/$BACKUP_ZIP

      curl -s --location "$ACTUAL_BUDGET_URL/sync/download-user-file" --header "X-ACTUAL-TOKEN: $TOKEN" --header "X-ACTUAL-FILE-ID: $FILE_ID" --output "$LOCAL_DIR/$BACKUP_ZIP"


      #curl -s -X POST https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage -d chat_id=-1002509650347 -d text="#actual: #startedBackup"

      ### Append to remote Borg repository
      echo appending to remote repo
      borg create $REMOTE_HOST$REMOTE_BACKUP_PATH::{now} /srv/archive/backup/./actual/ || STATUS=$?
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
      curl -s -X POST https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage -d chat_id=-1002509650347 -d text="#actual-budget: $MESSAGE Tempo impiegato: $minutes min e $seconds sec"
      exit $STATUS
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    restartIfChanged = false;
  };
}
