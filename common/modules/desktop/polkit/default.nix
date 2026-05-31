{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.modules.desktop.polkit;
in {
  options.modules.desktop.polkit = {
    enable = lib.mkEnableOption "Polkit Authentication Agent";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      polkit_gnome
    ];

    modules.startup.programs = [
      "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
    ];
  };
}
