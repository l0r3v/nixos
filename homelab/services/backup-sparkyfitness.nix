{
  config,
  pkgs,
  ...
}: let
  dbPasswordFile = config.sops.secrets."sparkyfitness/db_password".path;
  borgPassphraseFile = config.sops.secrets."borgbase/passphrase".path;
  borgSshKeyFile = config.sops.secrets."borgbase/ssh_key".path;
  borgRemoteHostFile = config.sops.secrets."borgbase/forgejo/remote_host".path;
  telegramBotTokenFile = config.sops.secrets.telegram_bot_token.path;
in {
  sops.secrets = {
    "sparkyfitness/db_password" = {};
  };

  systemd.timers."backup-sparkyfitness" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "03:00";
      Persistent = true;
      RandomizedDelaySec = 300;
    };
  };

  systemd.services."backup-sparkyfitness" = {
    path = with pkgs; [borgbackup postgresql_18 docker];
    script = ''
      set -eu
      START=$(date +%s)
      STATUS=0
      BACKUP_NAME="sparkyfitness-{now:%Y-%m-%dT%H:%M:%S}"

      echo "=== SparkyFitness backup ==="
      echo "Dumping PostgreSQL database..."

      DBPASS=$(cat ${dbPasswordFile})
      DUMP_FILE="/tmp/sparkyfitness-dump.sql.gz"

      docker exec sparkyfitness-db pg_dump -U sparky sparkyfitness_db \
        | gzip > "$DUMP_FILE"

      DUMP_SIZE=$(du -h "$DUMP_FILE" | cut -f1)
      echo "Dump size: $DUMP_SIZE"

      echo "Sending to BorgBase..."
      export BORG_PASSCOMMAND="cat ${borgPassphraseFile}"
      export BORG_RSH="ssh -i ${borgSshKeyFile} -o StrictHostKeyChecking=no"
      REMOTE_HOST=$(cat ${borgRemoteHostFile})
      REPO="$REMOTE_HOST./repo"

      borg create \
        --compression lz4 \
        --stats \
        "$REPO::$BACKUP_NAME" \
        "$DUMP_FILE" || STATUS=$?

      rm -f "$DUMP_FILE"

      END=$(date +%s)
      DURATION=$((END - START))
      MIN=$((DURATION / 60))
      SEC=$((DURATION % 60))

      if [ "$STATUS" -eq 0 ]; then
        MSG="✅ SparkyFitness backup completato (${MIN}m${SEC}s, $DUMP_SIZE)"
      else
        MSG="❌ SparkyFitness backup FALLITO (exit $STATUS) @Lorevocator"
      fi

      echo "$MSG"
      curl -s -X POST "https://api.telegram.org/bot$(cat ${telegramBotTokenFile})/sendMessage" \
        -d chat_id=-1002509650347 \
        -d message_thread_id=5596 \
        -d text="#sparky: $MSG"
    '';

    serviceConfig = {
      Type = "oneshot";
      User = "root";
      LogsDirectory = "backup-sparkyfitness";
    };
  };
}
