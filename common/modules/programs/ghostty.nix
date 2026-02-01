{
  config,
  lib,
  ...
}: let
  cfg = config.modules.programs.ghostty;
in {
  options.modules.programs.ghostty.enable = lib.mkEnableOption "ghostty";
  config = lib.mkIf cfg.enable {
    home-manager.users.lorev = _: {
      programs.ghostty = {
        enable = true;
        settings = {
          confirm-close-surface = true;
          quit-after-last-window-closed-delay = "1h";
        };
      };
    };
  };
}
