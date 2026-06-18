{config, lib, pkgs, ...}:
let
  cfg = config.services.sparkyfitness;
in {
  options.services.sparkyfitness = {
    enable = lib.mkEnableOption "SparkyFitness — AI-powered fitness tracker";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "fit.pasqui.casa";
      description = "Main domain for the web app";
    };

    frontendPort = lib.mkOption {
      type = lib.types.port;
      default = 3004;
      description = "Frontend (SPA nginx) port";
    };

    mcpPort = lib.mkOption {
      type = lib.types.port;
      default = 3001;
      description = "MCP server port (internal, not exposed via tunnel)";
    };

    dbName = lib.mkOption {
      type = lib.types.str;
      default = "sparkyfitness";
      description = "PostgreSQL database name";
    };
  };

  config = lib.mkIf cfg.enable {
    # ─── Tunnel (only web app, MCP è interno) ──────────────────────────────
    homelab.tunnelRoutes = {
      "${cfg.domain}" = "http://localhost:${toString cfg.frontendPort}";
    };

    # ─── Secrets ────────────────────────────────────────────────────────────
    sops.secrets = {
      "sparkyfitness/db_password" = {};
      "sparkyfitness/app_db_password" = {};
      "sparkyfitness/better_auth_secret" = {};
      "sparkyfitness/api_encryption_key" = {};
      "sparkyfitness/email_password" = {};
    };

    sops.templates."sparkyfitness.env".content = ''
      SPARKY_FITNESS_DB_PASSWORD=${config.sops.placeholder."sparkyfitness/db_password"}
      SPARKY_FITNESS_APP_DB_PASSWORD=${config.sops.placeholder."sparkyfitness/app_db_password"}
      BETTER_AUTH_SECRET=${config.sops.placeholder."sparkyfitness/better_auth_secret"}
      SPARKY_FITNESS_API_ENCRYPTION_KEY=${config.sops.placeholder."sparkyfitness/api_encryption_key"}
      SPARKY_FITNESS_EMAIL_PASS=${config.sops.placeholder."sparkyfitness/email_password"}
      SPARKY_FITNESS_API_KEY=${config.sops.placeholder."hermes/sparky_key"}
    '';

    # ─── Container: Backend (porta 3010) ───────────────────────────────────
    virtualisation.oci-containers.containers."sparkyfitness-server" = {
      image = "codewithcj/sparkyfitness_server:latest";
      ports = ["3010:3010/tcp"];
      environment = {
        SPARKY_FITNESS_DB_HOST = "host.docker.internal";
        SPARKY_FITNESS_DB_PORT = "5432";
        SPARKY_FITNESS_DB_NAME = cfg.dbName;
        SPARKY_FITNESS_DB_USER = "sparky";
        SPARKY_FITNESS_APP_DB_USER = "sparkyapp";
        SPARKY_FITNESS_FRONTEND_URL = "https://${cfg.domain}";
        SPARKY_FITNESS_ADMIN_EMAIL = "lorenzopasqui@gmail.com";
        SPARKY_FITNESS_MCP_URL = "http://host.docker.internal:${toString cfg.mcpPort}";
        ALLOW_PRIVATE_NETWORK_CORS = "true";
      };
      environmentFiles = [config.sops.templates."sparkyfitness.env".path];
      volumes = [
        "/srv/archive/sparkyfitness/backup:/app/SparkyFitnessServer/backup:rw"
        "/srv/archive/sparkyfitness/uploads:/app/SparkyFitnessServer/uploads:rw"
      ];
      extraOptions = [
        "--add-host=host.docker.internal:host-gateway"
      ];
    };

    # ─── Container: Frontend (porta 3004 → 80) ─────────────────────────────
    virtualisation.oci-containers.containers."sparkyfitness-frontend" = {
      image = "codewithcj/sparkyfitness:latest";
      ports = ["${toString cfg.frontendPort}:80/tcp"];
      environment = {
        SPARKY_FITNESS_FRONTEND_URL = "https://${cfg.domain}";
        SPARKY_FITNESS_SERVER_HOST = "host.docker.internal";
        SPARKY_FITNESS_SERVER_PORT = "3010";
      };
      extraOptions = [
        "--add-host=host.docker.internal:host-gateway"
      ];
    };

    # ─── Container: MCP (porta 3001, solo interno) ─────────────────────────
    virtualisation.oci-containers.containers."sparkyfitness-mcp" = {
      image = "codewithcj/sparkyfitness_mcp:latest";
      ports = ["${toString cfg.mcpPort}:3001/tcp"];
      environment = {
        SPARKY_FITNESS_DB_HOST = "host.docker.internal";
        SPARKY_FITNESS_DB_PORT = "5432";
        SPARKY_FITNESS_DB_NAME = cfg.dbName;
        SPARKY_FITNESS_DB_USER = "sparky";
        SPARKY_FITNESS_APP_DB_USER = "sparkyapp";
        MCP_TRANSPORT = "http";
        SPARKY_FITNESS_SERVER_HOST = "host.docker.internal";
        SPARKY_FITNESS_SERVER_PORT = "3010";
        SPARKY_FITNESS_FRONTEND_URL = "https://${cfg.domain}";
        ALLOW_PRIVATE_NETWORK_CORS = "true";
        SPARKY_FITNESS_EXTRA_TRUSTED_ORIGINS = "https://${cfg.domain}";
      };
      environmentFiles = [config.sops.templates."sparkyfitness.env".path];
      volumes = [
        "/srv/archive/sparkyfitness/mcp:/app/SparkyFitnessMCP/data:rw"
      ];
      extraOptions = [
        "--add-host=host.docker.internal:host-gateway"
      ];
    };

    # ─── Restart policy ─────────────────────────────────────────────────────
    systemd.services."docker-sparkyfitness-server" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "on-failure";
        RestartMaxDelaySec = lib.mkOverride 90 "1m";
        RestartSec = lib.mkOverride 90 "100ms";
        RestartSteps = lib.mkOverride 90 9;
      };
      after = ["docker.service" "postgresql.service"];
      requires = ["docker.service"];
      wantedBy = ["multi-user.target"];
    };

    systemd.services."docker-sparkyfitness-frontend" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "on-failure";
        RestartMaxDelaySec = lib.mkOverride 90 "1m";
        RestartSec = lib.mkOverride 90 "100ms";
        RestartSteps = lib.mkOverride 90 9;
      };
      after = ["docker.service" "docker-sparkyfitness-server.service"];
      requires = ["docker.service"];
      wantedBy = ["multi-user.target"];
    };

    systemd.services."docker-sparkyfitness-mcp" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "on-failure";
        RestartMaxDelaySec = lib.mkOverride 90 "1m";
        RestartSec = lib.mkOverride 90 "100ms";
        RestartSteps = lib.mkOverride 90 9;
      };
      after = ["docker.service" "docker-sparkyfitness-server.service" "postgresql.service"];
      requires = ["docker.service"];
      wantedBy = ["multi-user.target"];
    };

    # ─── Crea cartelle dati ────────────────────────────────────────────────
    systemd.tmpfiles.rules = [
      "d /srv/archive/sparkyfitness/backup 0755 hspasqui users -"
      "d /srv/archive/sparkyfitness/uploads 0755 hspasqui users -"
      "d /srv/archive/sparkyfitness/mcp 0755 hspasqui users -"
    ];
  };
}
