{
  config,
  pkgs,
  ...
}: {
  sops.secrets = {
    "dockers/gitea/action_token" = {};
  };
  sops.templates."gitea-action-token" = {
    content = ''
      ${config.sops.placeholder."dockers/gitea/action_token"}
    '';
    owner = "gitea-runner";
    group = "gitea-runner";
  };
  services.gitea-actions-runner = {
    instances.actions = {
      enable = true;
      name = "nix-runner";
      url = "https://git.pasqui.casa";
      token = "Gcu9mhdBD1H3hlDbOLGlUhCZ9miWZ4cbE7s3GBGC";
      labels = [ "ubuntu-latest" ];
      hostPackages = with pkgs; [
        nodejs
        bash
        coreutils
        curl
        gawk
        gitMinimal
        gnused
        nodejs
        wget
      ];
      settings = {
      };
    };
  };
}
