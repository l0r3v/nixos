{lib, pkgs, ...}: let
  webhookPort = 9099;
in {
  systemd.services.notes-webhook = {
    description = "Forgejo webhook receiver for garden rebuild";
    after = ["network.target" "caddy.service"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "simple";
      User = "hspasqui";
      WorkingDirectory = "/home/hspasqui/notes";
      ExecStart = "${pkgs.python3}/bin/python3 /home/hspasqui/notes/garden/webhook.py";
      Restart = "on-failure";
      RestartSec = 5;
      Environment = [
        "WEBHOOK_PORT=${toString webhookPort}"
        "REBUILD_CMD=cd /home/hspasqui/notes/.quartz && ${pkgs.nodejs_22}/bin/node quartz/bootstrap-cli.mjs build -d /home/hspasqui/notes/Garden -o /home/hspasqui/notes/public 2>&1"
      ];
      # Read secret from file
      EnvironmentFile = "-/home/hspasqui/.notes-webhook-secret";
    };
  };
}
