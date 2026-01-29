# Configurazione Authentik NixOS
# Sostituisce i container Docker con il modulo nativo
{
  config,
  pkgs,
  ...
}: {
  # ============================================================================
  # AUTHENTIK - Modulo NixOS nativo
  # ============================================================================

  services.authentik = {
    enable = true;

    # File con i secrets (generato automaticamente da sops template)
    environmentFile = config.sops.templates."authentik.env".path;

    settings = {
      # Network configuration
      listen = {
        http = "127.0.0.1:9091";
        https = "127.0.0.1:9443";
      };

      # Email configuration (gestita tramite environmentFile)
      email = {
        port = 587;
        use_tls = true;
        use_ssl = false;
        timeout = 10;
      };

      # Disable analytics
      disable_startup_analytics = true;
      disable_update_check = false;

      # Avatar settings
      avatars = "initials";

      # Logging
      log_level = "info";

      # Error reporting (disabilitato per privacy)
      error_reporting = {
        enabled = false;
        send_pii = false;
      };

      # Redis (gestito automaticamente dal modulo)
      # PostgreSQL (gestito automaticamente dal modulo)
    };
  };

  # ============================================================================
  # SOPS - Configurazione secrets (usa il tuo file esistente!)
  # ============================================================================

  # Importa i segreti dal tuo file esistente
  sops.secrets = {
    "authentik/pg_pass" = {};
    "authentik/secret_key" = {};
    "authentik/email_host" = {};
    "authentik/email_password" = {};
    "authentik/email_from" = {};
    "authentik/email_username" = {};
  };

  sops.templates."authentik.env" = {
    content = ''
      PG_PASS=${config.sops.placeholder."authentik/pg_pass"}
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

  # ============================================================================
  # NETWORKING - Firewall (opzionale)
  # ============================================================================

  # Se vuoi esporre direttamente (non consigliato, usa reverse proxy)
  # networking.firewall.allowedTCPPorts = [ 9000 9443 ];

  # ============================================================================
  # BACKUP - PostgreSQL automatico (opzionale ma consigliato)
  # ============================================================================

  services.postgresqlBackup = {
    enable = true;
    databases = ["authentik"];
    startAt = "*-*-* 03:00:00"; # Backup giornaliero alle 3 AM
    location = "/var/backup/postgresql";
    compression = "zstd";
  };

  # ============================================================================
  # NOTE IMPORTANTI
  # ============================================================================

  # 1. Il modulo NixOS crea automaticamente:
  #    - Database PostgreSQL locale
  #    - Redis locale
  #    - Servizi systemd per server e worker
  #
  # 2. I dati sono salvati in:
  #    - /var/lib/postgresql (database)
  #    - /var/lib/redis-authentik (redis)
  #    - /var/lib/authentik (media files)
  #
  # 3. Per la migrazione, dovrai:
  #    - Fare dump del database Docker
  #    - Importarlo nel PostgreSQL NixOS
  #    - Copiare /media se hai file custom
}
