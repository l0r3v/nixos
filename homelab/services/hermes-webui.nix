{
  config,
  lib,
  pkgs,
  ...
}:
let
  webuiPort = 8787;
  webuiStateDir = "/home/hspasqui/.hermes/webui";
  # Hermes-agent Python env — needed by WebUI for agent/hermes_cli imports.
  # Override the elocke package to use the full hermes-agent env rather than
  # the minimal default (pyyaml + cryptography only). This avoids
  # ModuleNotFoundError for hermes-agent modules and pydantic_core C extensions.
  hermesPythonEnv = config.services.hermes-agent.package.passthru.hermesVenv;
  hermesWebuiPkg = pkgs.hermes-webui.override {
    inherit hermesPythonEnv;
  };
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
    after = ["network-online.target"];
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
      ExecStart = "${hermesWebuiPkg}/bin/hermes-webui";
      Restart = "on-failure";
      RestartSec = 10;
      EnvironmentFile = config.sops.templates."hermes-webui-env".path;
    };
  };
}
