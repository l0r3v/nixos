{
  lib,
  config,
  ...
}: let
  cfg = config.modules.desktop.ly;
in {
  options.modules.desktop.ly = {
    enable = lib.mkEnableOption "Ly Display Manager (TUI)";
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.ly = {
      enable = true;

      settings = {
        animation = "doom";
        asterisk = "/#";
        bigclock = "it";
        clock = "%a %d %b %R";
        lang = "it";
        hide_borders = true;
        text_input_frame = "none";

        save = true;
        load = true;
      };
    };
    security.pam.services.ly.enableGnomeKeyring = true;
    services.gnome.gnome-keyring.enable = true;
    services.displayManager.gdm.enable = lib.mkForce false;
    services.xserver.displayManager.lightdm.enable = lib.mkForce false;
    services.displayManager.sddm.enable = lib.mkForce false;
  };
}
