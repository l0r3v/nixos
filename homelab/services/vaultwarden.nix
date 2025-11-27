{config, ...}: {
  sops.secrets = {
    "vaultwarden/admin_token" = {};
    "vaultwarden/smtp_password" = {};
    "vaultwarden/smtp_username" = {};
    "vaultwarden/sso_client_id" = {};
    "vaultwarden/sso_client_secret" = {};
  };

  sops.templates."vaultwarden.env".content = ''
    ADMIN_TOKEN=${config.sops.placeholder."vaultwarden/admin_token"}
    SMPT_PASSWORD=${config.sops.placeholder."vaultwarden/smtp_password"}
    SMPT_USERNAME=${config.sops.placeholder."vaultwarden/smtp_username"}
    SSO_CLIENT_ID=${config.sops.placeholder."vaultwarden/sso_client_id"}
    SSO_CLIENT_SECRET=${config.sops.placeholder."vaultwarden/sso_client_secret"}
  '';

  services.vaultwarden = {
    enable = true;
    backupDir = "/srv/archive/vaultwarden";
    environmentFile = config.sops.templates."vaultwarden.env".path;
    config = {
      DOMAIN = "https://pass.pasqui.casa";
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 7277;
      ROCKET_LOG = "critical";

      SMTP_HOST = "smtp.mail.me.com";
      SMTP_PORT = 587;
      SMTP_SECURITY = "starttls";
      SMTP_SSL = true;

      SMTP_FROM = "security@pasqui.casa";
      SMTP_FROM_NAME = "Vault di Casa Pasqui";

      SSO_ENABLED = true;
      SSO_AUTHORITY = "https://auth.pasqui.casa/application/o/vaultwarden/";
      SSO_SCOPES = "openid email profile offline_access";
      SSO_ALLOW_UNKNOWN_EMAIL_VERIFICATION = false;
      SSO_CLIENT_CACHE_EXPIRATION = 0;
      SSO_ONLY = true; # Set to true to disable email+master password login and require SSO
      SSO_SIGNUPS_MATCH_EMAIL = true; # Match first SSO login to existing account by email
    };
  };
}
