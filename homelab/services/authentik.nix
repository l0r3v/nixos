{config, ...}: {
  sops.secrets = {
    "dockers/authentik/pg_pass" = {};
    "dockers/authentik/secret_key" = {};
    "dockers/authentik/email_host" = {};
    "dockers/authentik/email_password" = {};
    "dockers/authentik/email_from" = {};
    "dockers/authentik/email_username" = {};
  };
  sops.templates."authentik.env".content = ''
    PG_PASS=${config.sops.placeholder."dockers/authentik/pg_pass"}
    AUTHENTIK_SECRET_KEY=${config.sops.placeholder."dockers/authentik/secret_key"}
    AUTHENTIK_EMAIL__HOST=${config.sops.placeholder."dockers/authentik/email_host"}
    AUTHENTIK_EMAIL__PASSWORD=${config.sops.placeholder."dockers/authentik/email_password"}
    AUTHENTIK_EMAIL__FROM=${config.sops.placeholder."dockers/authentik/email_from"}
    AUTHENTIK_EMAIL__USERNAME=${config.sops.placeholder."dockers/authentik/email_username"}
    AUTHENTIK_EMAIL__PORT="587"
    AUTHENTIK_EMAIL__TIMEOUT="10"
    AUTHENTIK_EMAIL__USE_SSL="false"
    AUTHENTIK_EMAIL__USE_TLS="true"
  '';

  services.authentik = {
    enable = true;
    environmentFile = config.sops.templates."authentik.env".path;
    settings = {
      disable_startup_analytics = true;
      avatars = "initials";
    };
  };
}
