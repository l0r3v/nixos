{
  ...
}: {
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/hspasqui/.config/sops/age/keys.txt";

    secrets.telegram_bot_token = {};
  };
}
