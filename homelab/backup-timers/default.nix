{...}: {
  imports = [
    ./gitea.nix
    ./immich.nix
    ./owncloud.nix
    ./actual-budget.nix
  ];
  sops.secrets.telegram_bot_token = {};
}
