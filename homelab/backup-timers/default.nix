{...}: {
  imports = [
    ./actual-budget.nix
    ./authentik.nix
    ./immich.nix
    ./owncloud.nix
  ];
  sops.secrets.telegram_bot_token = {};
}
