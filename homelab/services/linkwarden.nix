{config, ...}: {
  sops.secrets = {
    "linkwarden/auth_client_id" = {};
    "linkwarden/auth_client_secret" = {};
    "linkwarden/postgres_pass" = {};
    "linkwarden/nextauth" = {};
  };
  sops.templates."linkwarden.env".content = ''
    NEXTAUTH_URL=https://link.pasqui.casa/api/v1/auth
    NEXT_PUBLIC_AUTHENTIK_ENABLED=true
    AUTHENTIK_ISSUER=https://auth.pasqui.casa/application/o/linkwarden
    AUTHENTIK_CLIENT_ID=${config.sops.placeholder."linkwarden/auth_client_id"}
    POSTGRES_PASSWORD=${config.sops.placeholder."linkwarden/postgres_pass"}
    AUTHENTIK_CLIENT_SECRET=${config.sops.placeholder."linkwarden/auth_client_secret"}
    NEXTAUTH_SECRET=${config.sops.placeholder."linkwarden/nextauth"}
  '';

  services.linkwarden = {
    enable = true;
    port = 3390;
    openFirewall = true;
    storageLocation = "/srv/archive/linkwarden";
    environmentFile = config.sops.templates."linkwarden.env".path;
  };
}
