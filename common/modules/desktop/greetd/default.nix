{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.modules.desktop.greetd;

  greeterCommands = {
    tuigreet = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --sessions '${cfg.sessionsPath}'";
    gtkgreet = "${pkgs.gtkgreet}/bin/gtkgreet";
    wlgreet = "${pkgs.wlgreet}/bin/wlgreet";
  };

  greeterCommand = greeterCommands.${cfg.greeter} or greeterCommands.tuigreet;
in {
  options.modules.desktop.greetd = {
    enable = lib.mkEnableOption "greetd Display Manager";

    greeter = lib.mkOption {
      type = lib.types.enum ["tuigreet" "gtkgreet" "wlgreet"];
      default = "tuigreet";
      description = "Which greeter to use. tuigreet is TUI-based, gtkgreet supports fprintd, wlgreet is Wayland-native.";
    };

    sessionsPath = lib.mkOption {
      type = lib.types.str;
      default = "/run/current-system/sw/share/wayland-sessions:/run/current-system/sw/share/xsessions";
      description = "Colon-separated paths where session .desktop files are located.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = greeterCommand;
          user = "greeter";
        };
      };
    };

    security.pam.services.greetd.enableGnomeKeyring = true;
    services.gnome.gnome-keyring.enable = true;

    services.displayManager.gdm.enable = lib.mkForce false;
    services.xserver.displayManager.lightdm.enable = lib.mkForce false;
    services.displayManager.sddm.enable = lib.mkForce false;
  };
}
