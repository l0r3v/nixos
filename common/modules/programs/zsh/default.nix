{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.modules.programs.zsh;
  hostname = config.networking.hostName;
in {
  options.modules.programs.zsh = {
    enable = lib.mkEnableOption "zsh and oh-my-zsh";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh.enable = true;
    home-manager.users.lorev = {...}: {
      home.file = {
        ".p10k.zsh".source = ./p10k.zsh;
      };
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        initContent = ''
                if [[ -r "${pkgs.zsh-powerlevel10k}/p10k-instant-prompt-finalize.zsh" ]]; then
                  source "\${pkgs.zsh-powerlevel10k}/p10k-instant-prompt-finalize.zsh"
                fi
                eval "$(zoxide init --cmd cd zsh)"
                source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
                [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
                function y() {
          	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
          	yazi "$@" --cwd-file="$tmp"
          	IFS= read -r -d \'\' cwd < "$tmp"
          	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
          	rm -f -- "$tmp"
          }
        '';
        oh-my-zsh = {
          enable = true;
          plugins = ["git" "eza" "fzf" "safe-paste" "ssh" "ssh-agent" "zoxide"];
        };
        shellAliases =
          {
            ll = "ls -l";
          }
          // (lib.optionalAttrs (hostname == "XPSnixos") {
            bat = "sudo /run/current-system/specialisation/battery-saver/bin/switch-to-configuration test";
            perf = "sudo /run/current-system/bin/switch-to-configuration test";
          });

        history.size = 10000;
      };
    };
  };
}
