{config, ...}: {
  sops.secrets = {
    "mealie/smtp_password" = {};
    "mealie/smtp_username" = {};
    "mealie/sso_client_id" = {};
    "mealie/sso_client_secret" = {};
  };

  sops.templates."mealie.env".content = ''
    SMPT_PASSWORD=${config.sops.placeholder."mealie/smtp_password"}
    SMPT_USER=${config.sops.placeholder."mealie/smtp_username"}
    OIDC_CLIENT_ID=${config.sops.placeholder."mealie/sso_client_id"}
    OIDC_CLIENT_SECRET=${config.sops.placeholder."mealie/sso_client_secret"}
    OIDC_PROVIDER_NAME=authentik
    OIDC_CONFIGURATION_URL=https://auth.pasqui.casa/application/o/mealie/.well-known/openid-configuration
    OIDC_SIGNUP_ENABLED=true
    OIDC_USER_GROUP=mealie-users
    OIDC_ADMIN_GROUP=mealie-admins
    OIDC_AUTO_REDIRECT=true
    OIDC_REMEMBER_ME=true
  '';

  services.mealie = {
    enable = true;
    settings = {
      ALLOW_SIGNUP = "false";
      TZ = "IT";
      SMTP_HOST = "smtp.mail.me.com";
      SMTP_PORT = 587;
      SMTP_AUTH_STRATEGY = "TLS";
      SMTP_SSL = true;
      SMTP_FROM = "info@pasqui.casa";
      SMTP_FROM_NAME = "Mealie casa Pasqui";
      OIDC_AUTH_ENABLED = true;
    };
    credentialsFile = config.sops.templates."mealie.env".path;
  };
}
