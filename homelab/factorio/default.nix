{
  pkgs,
  config,
  lib,
  ...
}: {
  #nixpkgs.overlays = [
  #  (import ./factorio-overlay.nix)
  #];
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
