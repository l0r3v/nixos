{config,...}:{
  
  sops.secrets = {
    "dockers/gitea/action_token" = {};
  };
  sops.templates."gitea-action-token".content = ''
    ${config.sops.placeholder."dockers/gitea/action_token"}
  '';
  services.gitea-action-runner = {
    instances = {
      enable = true;
      name = "nix-runner";
      url = "https://git.pasqui.casa";
      tokenFile = config.sops.templates."gitea-action-token".path;
      labels = [ "ubuntu-latest" "nix" ];
    };
  };
}
