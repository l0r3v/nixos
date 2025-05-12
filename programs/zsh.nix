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
    '';
    oh-my-zsh = {
      enable = true;
      plugins = ["git" "eza" "fzf" "safe-paste" "ssh" "ssh-agent" "zoxide"];
    };
    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch --flake /home/lorev/nixos-config/# && nh home switch";
      updateServer = "sudo nixos-rebuild switch --flake /home/lorev/nixos-config/#homelab --target-host root@homelab --verbose";
    };
    history.size = 10000;
  };
}
