{
  lib,
  config,
  ...
}: let
  cfg = config.modules.programs.rofi-rbw;
in {
  options.modules.programs.rofi-rbw = {
    enable = lib.mkEnableOption "rofi-rbw";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.lorev = {pkgs, ...}: {
      home.packages = [
        pkgs.rbw
        pkgs.rofi-rbw-wayland
      ];
      home.file.".config/rofi-rbw.rc".text = ''
        action = type
        clear-after = 20
        use-notify-send = true
      '';
      programs.niri.settings.binds."Control+Shift+L".action.spawn = [
        "rofi-rbw"
        "--no-help"
        "--keybindings"
        "Ctrl+1:type:username,Ctrl+2:type:password,Ctrl+3:type:totp"
      ];
    };
  };
}
