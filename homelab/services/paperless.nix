{config, ...}: {
  nixpkgs.overlays = [
    (self: super: {
      paperless-ngx = super.paperless-ngx.overrideAttrs (old: {
        doCheck = false;
      });
    })
  ];
  sops.secrets = {
    "paperless/admin_password" = {};
    "paperless/db_password" = {};
    "paperless/socialaccount_providers" = {};
    "paperless/secret_key" = {};
  };

  sops.templates."paperless.env".content = ''
    PAPERLESS_DBPASS=${config.sops.placeholder."paperless/db_password"}
    PAPERLESS_SECRET_KEY=${config.sops.placeholder."paperless/secret_key"}
    PAPERLESS_ADMIN_USER=lorev
    PAPERLESS_ADMIN_PASSWORD=${config.sops.placeholder."paperless/admin_password"}
    PAPERLESS_ENABLE_ALLAUTH=true
    PAPERLESS_APPS=allauth.socialaccount.providers.openid_connect
    PAPERLESS_SOCIALACCOUNT_PROVIDERS=${config.sops.placeholder."paperless/socialaccount_providers"}
  '';
  services.paperless = {
    enable = true;
    dataDir = "/srv/archive/paperless";
    environmentFile = config.sops.templates."paperless.env".path;
    database.createLocally = true;

    settings = {
      PAPERLESS_OCR_LANGUAGE = "ita+eng";
      PAPERLESS_OCR_USER_ARGS = {
        optimize = 1;
        pdfa_image_compression = "lossless";
      };
      PAPERLESS_URL = "https://papers.pasqui.casa";
    };
  };
}
