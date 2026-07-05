{
  config,
  lib,
  pkgs,
  ...
}:
let
  webuiPort = 8787;
  webuiStateDir = "/home/hspasqui/.hermes/webui";

  # Package dal dbeley flake — self-contained con pyyaml + cryptography.
  # Il dbeley package NON include hermes_cli; lo aggiungiamo via PYTHONPATH
  # puntando all'agent package (gestito da services.hermes-agent).
  hermesWebuiPkg = pkgs.hermes-webui;
  hermesAgentPkg = config.services.hermes-agent.package;
  hermesAgentPythonPath = "${hermesAgentPkg}/${pkgs.python3.sitePackages}";
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
      # Condivide i moduli Python dell'agent così il WebUI può importare hermes_cli
      # e comunicare col gateway via API interne (non spawna un gateway suo).
      HERMES_WEBUI_AGENT_DIR = hermesAgentPythonPath;
      PYTHONPATH = hermesAgentPythonPath;
      PYTHONDONTWRITEBYTECODE = "1";
      PYTHONUNBUFFERED = "1";
    };

    serviceConfig = {
      Type = "simple";
      User = "hspasqui";
      Group = "users";
      WorkingDirectory = "/home/hspasqui";
      ExecStart = "${hermesWebuiPkg}/bin/hermes-webui";
      Restart = "on-failure";
      RestartSec = 10;
      EnvironmentFile = config.sops.templates."hermes-webui-env".path;
    };
  };
}
