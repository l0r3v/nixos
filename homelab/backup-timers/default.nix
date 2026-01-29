{...}: {
  imports = [
    ./actual-budget.nix
    ./authentik.nix
    ./gitea.nix
    ./immich.nix
    ./owncloud.nix
  ];
  sops.secrets.telegram_bot_token = {};
}
