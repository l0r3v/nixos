{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.modules.programs.gaming;
in {
  options.modules.programs.gaming.enable = lib.mkEnableOption "gaming";
  config = lib.mkIf cfg.enable {
    programs = {
      gamemode.enable = true;
      gamescope.enable = true;
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        extraCompatPackages = [
          pkgs.proton-ge-bin
        ];
      };
    };
    environment.systemPackages = with pkgs; [
      lutris
      winetricks
      heroic
      mangohud
      protontricks
      goverlay
      moonlight-qt
      ckan
    ];
    home-manager.users.lorev = _: {
    };
  };
}
