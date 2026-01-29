{config, ...}: {
  services.authentik = {
    enable = true;

    environmentFile = config.sops.templates."authentik.env".path;

    settings = {
      listen = {
        http = "127.0.0.1:9091";
        https = "127.0.0.1:9443";
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

  services.postgresqlBackup = {
    enable = true;
    databases = ["authentik"];
    startAt = "*-*-* 03:00:00"; # Backup giornaliero alle 3 AM
    location = "/var/backup/postgresql";
    compression = "zstd";
  };
}
