{
  config,
  lib,
  ...
}: let
  cfg = config.modules.programs.tmux;
in {
  options.modules.programs.tmux.enable = lib.mkEnableOption "tmux";

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;

      keyMode = "vi";
      shortcut = "a";
      baseIndex = 1;
      clock24 = true;
      terminal = "tmux-256color";
      historyLimit = 50000;
      newSession = true;
      extraConfig = "set -g allow-passthrough on";
    };
  };
}
