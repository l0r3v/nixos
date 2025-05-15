{config,...}:
{
    sops.secrets = {
    "dockers/miniflux/admin_password" = {};
  };

    sops.templates."miniflux.env".content = ''
    ADMIN_USERNAME=Lorenzo
    ADMIN_PASSWORD=${config.sops.placeholder."dockers/miniflux/admin_password"}
  '';

  services.miniflux= {
    enable = true;
    adminCredentialsFile = config.sops.templates."miniflux.env".path;
    config = {
      LISTEN_ADDR = "0.0.0.0:8031";
    };
  };
}
