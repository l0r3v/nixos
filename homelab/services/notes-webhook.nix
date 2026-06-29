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
      ];
      # Read secret from file — create it with:
      #   echo -n 'your-token' > /home/hspasqui/.notes-webhook-secret
      EnvironmentFile = "-/home/hspasqui/.notes-webhook-secret";
    };
  };
}
