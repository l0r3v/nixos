{
  config,
  pkgs,
  ...
}: {
  sops.secrets = {
    "dockers/gitea/action_token" = {
    owner = "gitea-runner";
    group = "gitea-runner";
    mode = "0440";
    };
  };
  sops.templates."gitea-action-token" = {
    content = ''
      ${config.sops.placeholder."dockers/gitea/action_token"}
    '';
    owner = "gitea-runner";
    group = "gitea-runner";
    mode = "0440";
  };
  services.gitea-actions-runner = {
    instances.actions = {
      enable = true;
      name = "nix-runner";
      url = "https://git.pasqui.casa";
      tokenFile = config.sops.templates.gitea-action-token.path;
      labels = [ "ubuntu-latest" "nixos-host:host"];
      hostPackages = with pkgs; [
        nodejs
        bash
        coreutils
        curl
        gawk
        git
        gnused
        nodejs
        wget
        tea
        nix
      ];
      settings = {
      };
    };
  };
}
