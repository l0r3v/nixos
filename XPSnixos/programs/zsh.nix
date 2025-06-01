{pkgs, ...}: {
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
    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch --flake /home/lorev/nixos/# --fast|& nom";
      upgrade = "sudo nixos-rebuild switch --flake /home/lorev/nixos/# |& nom";
      mobile = "sudo /nix/var/nix/profiles/system/specialisation/mobile/bin/swtich-to-configuration test";
      no-mobile = "sudo /nix/var/nix/profiles/system/bin/swtich-to-configuration switch";
      updateServer = "sudo nixos-rebuild switch --flake /home/lorev/nixos/homelab/#homelab --target-host root@homelab |& nom";
      nssh = "nvim oil-ssh://hspasqui@homelab/~";
    };
    history.size = 10000;
  };
}
