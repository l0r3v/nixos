{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.programs.tmux;
  colors = (config.lib.stylix or {}).colors or null;

  dotbarColors =
    if colors != null
    then ''
      set -g @tmux-dotbar-bg "#${colors.base00}"
      set -g @tmux-dotbar-fg "#${colors.base03}"
      set -g @tmux-dotbar-fg-current "#${colors.base05}"
      set -g @tmux-dotbar-fg-session "#${colors.base04}"
      set -g @tmux-dotbar-fg-prefix "#${colors.base0B}"
    ''
    else ''
      set -g @tmux-dotbar-bg "#1e1e2e"
      set -g @tmux-dotbar-fg "#585b70"
      set -g @tmux-dotbar-fg-current "#cdd6f4"
      set -g @tmux-dotbar-fg-session "#9399b2"
      set -g @tmux-dotbar-fg-prefix "#cba6f7"
    '';
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
      shortcut = "a";

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
        tmuxPlugins.tmux-fzf
        tmuxPlugins.dotbar
      ];

      extraConfig =
        ''
          set -g allow-passthrough on
          set -g renumber-windows on
          set -g base-index 1
          setw -g pane-base-index 1

          set -g @resurrect-capture-pane-contents 'on'

          set -g @sessionx-bind 'C-o'
          set -g @sessionx-layout 'reverse'
          set -g @sessionx-git-branch 'on'
          set -g @sessionx-zoxide-mode 'on'

          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'

          bind c new-window -c "#{pane_current_path}"
          bind C-h previous-window
          bind C-l next-window
          bind R source-file '/etc/tmux.conf'
          bind-key -T copy-mode-vi v send-keys -X begin-selection

          unbind s
          bind s split-window -h -c "#{pane_current_path}"


          bind C-M-h swap-window -t -1
          bind C-M-j swap-window

          #Gestione pannelli
          bind C-m join-pane -h -t :+
          bind C-M join-pane -v -t :+
          bind C-b break-pane

          TMUX_FZF_LAUNCH_KEY="C-f"
          TMUX_FZF_ORDER="pane|window|command"

          set -g @tmux-dotbar-right true
          set -g @tmux-dotbar-status-right-text " %H:%M "
          set -g @tmux-dotbar-rounded true
        ''
        + dotbarColors;
    };
  };
}
