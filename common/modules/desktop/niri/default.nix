{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.modules.desktop.niri;
in {
  options.modules.desktop.niri = {
    enable = lib.mkEnableOption "Niri Window Manager";
  };

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;
    programs.xwayland.enable = true;
    environment.systemPackages = with pkgs; [
      xwayland-satellite
      swaybg
    ];
    services.displayManager.sessionPackages = [
      pkgs.niri
    ];

    home-manager.users.lorev = {...}: {
      xdg.configFile."niri/config.kdl".source = ./config.kdl;
      programs.fuzzel.enable = true;
      stylix.targets.fuzzel.fonts.enable = false;

      home.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        MOZ_ENABLE_WAYLAND = "1";
        XDG_SESSION_TYPE = "wayland";
        XDG_CURRENT_DESKTOP = "Niri";
        XDG_SESSION_DESKTOP = "Niri";
        WLR_NO_HARDWARE_CURSORS = "1";
      };
    };
  };
}
