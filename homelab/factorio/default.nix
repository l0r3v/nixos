{
  pkgs,
  config,
  lib,
  ...
}: let
  mod-list-json = pkgs.writeText "mod-list.json" (
    builtins.toJSON ''
      mods = [
        {
          name = "base";
          enabled = true;
        }
        {
          name = "elevated-rails";
          enabled = true;
        }
        {
          name = "quality";
          enabled = true;
        }
        {
          name = "space-age";
          enabled = true;
        }
      ];
    ''
  );
in {
  nixpkgs.overlays = [
    (import ./factorio-overlay.nix)
  ];
  sops.secrets = {
    "factorio/game-pass" = {};
  };
  sops.templates."extraFactorioServerSettings.json".content = ''
    {
      "game-password": "${config.sops.placeholder."factorio/game-pass"}"
    }
  '';
  services.factorio = {
    enable = true;
    openFirewall = true;
    requireUserVerification = false;
    package = pkgs.factorio-headless;
    extraSettingsFile = config.sops.templates."extraFactorioServerSettings.json".path;
    admins = [
      "Lorev"
    ];
    allowedPlayers = [
      "Lorev"
      "Fedo"
    ];
  };
  #systemd.services.factorio.serviceConfig.RestartSec = 10;
  #systemd.services.factorio.postStart = ''
  #cat ${mod-list-json} > /var/lib/${config.services.factorio.stateDirName}/mod-list.json
  #'';
  systemd.services.factorio.wantedBy = lib.mkForce [];
}
