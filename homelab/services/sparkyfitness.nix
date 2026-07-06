# SparkyFitness — native NixOS deployment using the flake's NixOS module.
#
# Replaces the previous Docker-based deployment (db + frontend + server
# containers) with systemd services and local PostgreSQL, all built from
# the upstream flake.
#
# ── Migration notes ──────────────────────────────────────────────────
# The old Docker deployment ran a dedicated PostgreSQL 18 container with
# the sparkyfitness_db database and sparky/sparky_app roles.  To migrate:
#
#   1. Dump the existing database from the Docker container:
#        docker exec sparkyfitness-db pg_dump -U sparky sparkyfitness_db > dump.sql
#
#   2. Stop the Docker containers and disable the docker module.
#
#   3. Enable this module and deploy.  The sparkyfitness-db-init oneshot
#      below will create the sparky role and database in the local
#      PostgreSQL.
#
#   4. Restore the dump:
#        psql -U sparky -h 127.0.0.1 sparkyfitness_db < dump.sql
#
# ⚠  Deploy will fail binaurally until steps 1-3 are completed.
# ─────────────────────────────────────────────────────────────────────

{ inputs, config, pkgs, lib, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) system;
  sparkyfitness = inputs.sparkyfitness;
  backendPackage = sparkyfitness.packages.${system}.sparkyfitness-server;
  frontendPackage = sparkyfitness.packages.${system}.sparkyfitness-frontend;
in
{
  # ── Cloudflare tunnel route ───────────────────────────────────────
  homelab.tunnelRoutes = {
    "fit.pasqui.casa" = "http://localhost:3044";
  };

  # ── Secrets ───────────────────────────────────────────────────────
  sops.secrets = {
    "sparkyfitness/db_password" = { };
    "sparkyfitness/better_auth_secret" = { };
    "sparkyfitness/app_db_password" = { };
    "sparkyfitness/api_encryption_key" = { };
    "sparkyfitness/oidc_client_id" = { };
    "sparkyfitness/oidc_client_secret" = { };
    "borgbase/passphrase" = { };
    "borgbase/ssh_key" = { };
    "borgbase/sparkyfitness/remote_host" = { };
  };

  sops.templates."sparkyfitness.env".content = ''
    SPARKY_FITNESS_DB_PASSWORD=${config.sops.placeholder."sparkyfitness/db_password"}
    BETTER_AUTH_SECRET=${config.sops.placeholder."sparkyfitness/better_auth_secret"}
    SPARKY_FITNESS_APP_DB_PASSWORD=${config.sops.placeholder."sparkyfitness/app_db_password"}
    SPARKY_FITNESS_API_ENCRYPTION_KEY=${config.sops.placeholder."sparkyfitness/api_encryption_key"}
    SPARKY_FITNESS_OIDC_CLIENT_ID=${config.sops.placeholder."sparkyfitness/oidc_client_id"}
    SPARKY_FITNESS_OIDC_CLIENT_SECRET=${config.sops.placeholder."sparkyfitness/oidc_client_secret"}
  '';

  # ── NixOS module ──────────────────────────────────────────────────
  services.sparkyfitness = {
    enable = true;
    inherit backendPackage frontendPackage;

    port = 3010;
    frontendUrl = "https://fit.pasqui.casa";
    logLevel = "ERROR";

    environmentFile = config.sops.templates."sparkyfitness.env".path;

    database = {
      # Don't let the module touch the shared PostgreSQL config (the
      # homelab manages it in services/postgresql.nix).  We provision
      # the sparky role and database ourselves below.
      createLocally = false;
      host = "127.0.0.1";
      port = 5432;
      name = "sparkyfitness_db";
      user = "sparky";
      appUser = "sparky_app";
    };

    nginx = {
      enable = true;
      # Matches the cloudflared tunnel Host header so nginx serves
      # the right virtual server block.
      virtualHost = "fit.pasqui.casa";
    };

    extraEnvironment = {
      # OIDC / Authentik
      SPARKY_FITNESS_OIDC_AUTH_ENABLED = "true";
      SPARKY_FITNESS_OIDC_ISSUER_URL = "https://auth.pasqui.casa/application/o/sparkyfitness/";
      SPARKY_FITNESS_OIDC_PROVIDER_SLUG = "sparkyfitness";
      SPARKY_FITNESS_OIDC_PROVIDER_NAME = "Log in with Authentik";
      SPARKY_FITNESS_OIDC_SCOPE = "openid email group profile";
      SPARKY_FITNESS_OIDC_TOKEN_AUTH_METHOD = "client_secret_post";
      SPARKY_FITNESS_OIDC_AUTO_REGISTER = "true";
      SPARKY_FITNESS_OIDC_ADMIN_GROUP = "sparky_admin";
      SPARKY_FITNESS_DISABLE_EMAIL_LOGIN = "true";
    };
  };

  # ── nginx listen on a dedicated port ─────────────────────────────
  # The module's nginx virtualHost defaults to listening on *:80.
  # Pin it to 127.0.0.1:3044 so it doesn't collide with anything else
  # on port 80.
  services.nginx.virtualHosts."fit.pasqui.casa".listen = [
    { addr = "127.0.0.1"; port = 3044; }
  ];

  # ── Database initialisation ──────────────────────────────────────
  # Mirror what the module's `database.createLocally` does, but for
  # the shared homelab PostgreSQL instance.
  systemd.services.sparkyfitness-db-init = {
    description = "SparkyFitness database initialisation";
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
    wantedBy = [ "multi-user.target" ];
    before = [ "sparkyfitness.service" ];

    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      Group = "postgres";
      RemainAfterExit = true;
      EnvironmentFile = config.sops.templates."sparkyfitness.env".path;
    };

    path = [ config.services.postgresql.package ];

    script = ''
      set -euo pipefail
      DB="sparkyfitness_db"
      OWNER="sparky"
      APP="sparky_app"

      # Create / update the privileged owner role.
      if psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$OWNER'" | grep -q 1; then
        printf '%s\n' "ALTER ROLE \"$OWNER\" WITH LOGIN CREATEROLE PASSWORD :'passwd';" \
          | psql -v passwd="$SPARKY_FITNESS_DB_PASSWORD"
      else
        printf '%s\n' "CREATE ROLE \"$OWNER\" WITH LOGIN CREATEROLE PASSWORD :'passwd';" \
          | psql -v passwd="$SPARKY_FITNESS_DB_PASSWORD"
      fi

      # Create the database owned by the owner role.
      if ! psql -tAc "SELECT 1 FROM pg_database WHERE datname='$DB'" | grep -q 1; then
        psql -c "CREATE DATABASE \"$DB\" OWNER \"$OWNER\""
      else
        psql -c "ALTER DATABASE \"$DB\" OWNER TO \"$OWNER\""
      fi

      # Hand the public schema to the owner role.
      psql -d "$DB" -c "ALTER SCHEMA public OWNER TO \"$OWNER\""

      # The backend creates the limited application role at startup, but
      # pre-create it here so the env file is the single source of truth.
      if psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$APP'" | grep -q 1; then
        printf '%s\n' "ALTER ROLE \"$APP\" WITH LOGIN PASSWORD :'passwd';" \
          | psql -v passwd="$SPARKY_FITNESS_APP_DB_PASSWORD"
      else
        printf '%s\n' "CREATE ROLE \"$APP\" WITH LOGIN PASSWORD :'passwd';" \
          | psql -v passwd="$SPARKY_FITNESS_APP_DB_PASSWORD"
      fi
    '';
  };

  # ── Backup (nightly pg_dump → BorgBase) ──────────────────────────
  systemd.timers."backup-sparkyfitness" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "03:00";
      Persistent = true;
      RandomizedDelaySec = 300;
    };
  };

  systemd.services."backup-sparkyfitness" = {
    path = with pkgs; [ borgbackup gzip postgresql_18 curl util-linux ];
    script = ''
      #!/bin/sh
      set -eu

      STATUS=0
      TELEGRAM_BOT_TOKEN="$(cat ${config.sops.secrets.telegram_bot_token.path})"
      DUMP_FILE="/tmp/sparkyfitness-dump.sql.gz"

      export BORG_PASSCOMMAND="cat ${config.sops.secrets."borgbase/passphrase".path}"
      export BORG_RSH="ssh -i ${config.sops.secrets."borgbase/ssh_key".path} -o StrictHostKeyChecking=no"
      REMOTE_HOST=$(cat ${config.sops.secrets."borgbase/sparkyfitness/remote_host".path})
      REPO="$REMOTE_HOST./repo"

      start_time=$(date +%s)
      echo "=== SparkyFitness backup ==="
      echo "Dumping PostgreSQL database..."

      export PGPASSWORD="$SPARKY_FITNESS_DB_PASSWORD"
      pg_dump -U sparky -h 127.0.0.1 sparkyfitness_db \
        | gzip > "$DUMP_FILE"

      DUMP_SIZE=$(du -h "$DUMP_FILE" | cut -f1)
      echo "Dump size: $DUMP_SIZE"

      echo "Sending to BorgBase..."
      borg create \
        --compression lz4 \
        --stats \
        "$REPO::{now}" \
        "$DUMP_FILE" || STATUS=$?

      rm -f "$DUMP_FILE"

      end_time=$(date +%s)
      duration=$((end_time - start_time))
      minutes=$((duration / 60))
      seconds=$((duration % 60))

      if [ "$STATUS" -eq 0 ]; then
        MSG="✅ SparkyFitness backup completato con successo"
      else
        MSG="❌ Errore nel backup SparkyFitness (exit $STATUS) @Lorevocator"
      fi

      echo "Status $STATUS: $MSG"
      curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        -d chat_id=-1002509650347 \
        -d message_thread_id=5596 \
        -d text="#sparky: $MSG. Tempo impiegato: $minutes min e $seconds sec ($DUMP_SIZE)"

      exit $STATUS
    '';

    serviceConfig = {
      Type = "oneshot";
      User = "root";
      LogsDirectory = "backup-sparkyfitness";
      EnvironmentFile = config.sops.templates."sparkyfitness.env".path;
    };
    restartIfChanged = false;
  };
}
