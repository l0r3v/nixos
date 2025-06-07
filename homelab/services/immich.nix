{config, ...}: {
  sops.secrets = {
    "immich/db_password" = {};
  };

  sops.templates."immich.env".content = ''
    DB_PASSWORD=${config.sops.placeholder."immich/db_password"}
    POSTGRES_PASSWORD=${config.sops.placeholder."immich/db_password"}
  '';

  services.immich = {
    enable = true;
    port = 2283;
    host = "0.0.0.0";
    openFirewall = true;
    mediaLocation = "/srv/archive/immich/uploads";
    secretsFile = config.sops.templates."immich.env".path;
    environment = {
      TZ = "Europe/Rome";
    };
  };
}
