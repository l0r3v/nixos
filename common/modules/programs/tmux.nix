{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.programs.tmux;
in {
  options.modules.programs.tmux.enable = lib.mkEnableOption "tmux";

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;

      keyMode = "vi";
      baseIndex = 1;
      clock24 = true;
      terminal = "tmux-256color";
      historyLimit = 50000;
      newSession = true;

      plugins = with pkgs; [
        tmuxPlugins.sensible
        tmuxPlugins.yank
        tmuxPlugins.prefix-highlight
        tmuxPlugins.vim-tmux-navigator
        tmuxPlugins.extrakto
        tmuxPlugins.open
        tmuxPlugins.tmux-sessionx
        tmuxPlugins.resurrect
        tmuxPlugins.continuum
      ];

      extraConfig = ''
        set -g allow-passthrough on

        set -g @resurrect-capture-pane-contents 'on'

        set -g @continuum-restore 'on'
        set -g @continuum-save-interval '15'

        set -g @sessionx-bind 'o'
        set -g @sessionx-layout 'reverse'
        set -g @sessionx-git-branch 'on'
        set -g @sessionx-zoxide-mode 'on'
      '';
    };
  };
}
