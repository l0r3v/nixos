{config, ...}: {
  sops.secrets = {
    "dockers/miniflux/admin_password" = {};
    "dockers/miniflux/oauth2_client_id" = {};
    "dockers/miniflux/oauth2_client_secret" = {};
    "dockers/miniflux/oauth2_redirect_url" = {};
    "dockers/miniflux/oauth2_endpoint" = {};
  };

  sops.templates."miniflux.env".content = ''
    ADMIN_USERNAME=Lorenzo
    ADMIN_PASSWORD=${config.sops.placeholder."dockers/miniflux/admin_password"}
    OAUTH2_CLIENT_ID=${config.sops.placeholder."dockers/miniflux/oauth2_client_id"}
    OAUTH2_CLIENT_SECRET=${config.sops.placeholder."dockers/miniflux/oauth2_client_secret"}
    OAUTH2_REDIRECT_URL=${config.sops.placeholder."dockers/miniflux/oauth2_redirect_url"}
    OAUTH2_OIDC_DISCOVERY_ENDPOINT=${config.sops.placeholder."dockers/miniflux/oauth2_endpoint"}
  '';

  services.miniflux = {
    enable = true;
    adminCredentialsFile = config.sops.templates."miniflux.env".path;
    config = {
      OAUTH2_PROVIDER = "oidc";
      OAUTH2_USER_CREATION = 1;
      LISTEN_ADDR = "0.0.0.0:8031";
    };
  };
}
