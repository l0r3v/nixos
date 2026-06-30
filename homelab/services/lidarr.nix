{
  config,
  lib,
  pkgs,
  ...
}:
let
  port = 8686;
in
{
  sops.secrets = {
    "lidarr/api_key" = {
      owner = "hspasqui";
    };
  };

  systemd.tmpfiles.rules = [
    "d /srv/archive/music 2775 music music -"
    "d /srv/archive/downloads 2775 music music -"
    "d /srv/archive/lidarr 0755 music music -"
  ];

  systemd.services.lidarr = {
    description = "Lidarr";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "hspasqui";
      Group = "users";
      ExecStart = "${pkgs.lidarr}/bin/Lidarr --nobrowser --data=/srv/archive/lidarr";
      Restart = "on-failure";
      RestartSec = "5";
    };
  };
}
