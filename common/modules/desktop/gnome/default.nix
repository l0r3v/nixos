{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.modules.desktop.gnome;
in {
  options.modules.desktop.gnome = {
    enable = lib.mkEnableOption "gnome";
  };

  config = lib.mkIf cfg.enable {
    services.desktopManager.gnome.enable = true;
    environment.gnome.excludePackages = with pkgs; [
      papers
      gnome-photos
      gnome-tour
      cheese
      gnome-music
      gnome-terminal
      epiphany
      geary
      evince
      totem
      tali
      iagno
      hitori
      atomix
      gnome-weather
      gnome-maps
      simple-scan
      gnome-contacts
    ];

    environment.systemPackages = with pkgs; [
    ];

    home-manager.users.lorev = {...}: {
    };
  };
}
