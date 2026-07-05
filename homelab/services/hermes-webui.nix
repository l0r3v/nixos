{
  config,
  lib,
  pkgs,
  ...
}:
let
  webuiPort = 8787;
  webuiStateDir = "/home/hspasqui/.hermes/webui";

  hermesWebuiPkg = pkgs.hermes-webui;
  hermesAgentPkg = config.services.hermes-agent.package;

  # Start script che estrae HERMES_PYTHON dal wrapper dell'agent
  # (come fa il dbeley flake nel modulo Home Manager). Questo permette
  # al WebUI di usare il Python dell'agent con tutti i moduli hermes_cli,
  # senza doverli duplicare nel package WebUI.
  startScript = pkgs.writeShellScript "hermes-webui-start" ''
    # Estrai il Python dell'agent dal wrapper 'hermes'
    HERMES_PYTHON=$(grep -oP "HERMES_PYTHON='\K[^']+" ${hermesAgentPkg}/bin/hermes 2>/dev/null || true)

    if [ -n "$HERMES_PYTHON" ] && [ -x "$HERMES_PYTHON" ]; then
      cd ${hermesWebuiPkg}/share/hermes-webui
      exec "$HERMES_PYTHON" server.py
    else
      # Fallback: usa il Python del package WebUI (ha solo pyyaml+cryptography,
      # quindi import hermes_cli fallirà — ma almeno il server parte)
      exec ${hermesWebuiPkg}/bin/hermes-webui
    fi
  '';
in {
  # --- Sops secret for the WebUI password ---
  sops.secrets."hermes/webui_password" = {};

  # --- Env file: loaded by systemd, keeps password out of the Nix store ---
  sops.templates."hermes-webui-env".content = ''
    HERMES_WEBUI_PASSWORD=${config.sops.placeholder."hermes/webui_password"}
  '';

  # --- Ensure state directory exists ---
  systemd.tmpfiles.rules = [
    "d ${webuiStateDir} 0750 hspasqui users - -"
  ];

  # --- Systemd service ---
  systemd.services.hermes-webui = {
    description = "Hermes WebUI — browser interface for Hermes Agent";
    wantedBy = ["multi-user.target"];
    after = ["network-online.target" "hermes-agent.service"];
    wants = ["network-online.target"];

    environment = {
      HERMES_HOME = "/home/hspasqui/.hermes";
      HERMES_WEBUI_HOST = "0.0.0.0";
      HERMES_WEBUI_PORT = toString webuiPort;
      HERMES_WEBUI_STATE_DIR = webuiStateDir;
      PYTHONDONTWRITEBYTECODE = "1";
      PYTHONUNBUFFERED = "1";
    };

    serviceConfig = {
      Type = "simple";
      User = "hspasqui";
      Group = "users";
      WorkingDirectory = "/home/hspasqui";
      ExecStart = "${startScript}";
      Restart = "on-failure";
      RestartSec = 10;
      EnvironmentFile = config.sops.templates."hermes-webui-env".path;
    };
  };
}
