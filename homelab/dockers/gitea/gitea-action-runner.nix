{
  config,
  pkgs,
  ...
}: {
  sops.secrets = {
    "dockers/gitea/action_token" = {
    };
  };
  sops.templates."gitea-action-token" = {
    content = ''
      TOKEN=${config.sops.placeholder."dockers/gitea/action_token"}
    '';
    mode = "0444";
  };
  services.gitea-actions-runner = {
    instances.def = {
      enable = true;
      name = "nix-runner";
      url = "https://git.pasqui.casa";
      tokenFile = config.sops.templates."gitea-action-token".path;
      labels = ["ubuntu-latest" "nixos-host:host"];
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
