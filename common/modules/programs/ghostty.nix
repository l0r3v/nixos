{
  config,
  lib,
  pkgs,
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

          command = "${pkgs.tmux}/bin/tmux";
        };
      };

      programs.tmux = {
        enable = true;

        keyMode = "vi";
        baseIndex = 1;
        clock24 = true;
        terminal = "tmux-256color";
        historyLimit = 50000;
        newSession = true;
        extraConfig = "set -g allow-passthrough on";
      };
    };
  };
}
