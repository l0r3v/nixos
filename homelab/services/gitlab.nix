{config, ...}: {
  services.gitlab = {
    enable = true;
    databasePasswordFile = "${config.sops.templates.gitlab_db.path}";
    initialRootPasswordFile = "${config.sops.templates.gitlab_pass.path}";
    host = "gitlab.pasqui.casa";
    port = 44;
    user = "gitlab";
    databaseUsername = "gitlab";
    secrets = {
      otpFile = "${config.sops.templates.gitlab_otp.path}";
      jwsFile = "${config.sops.templates.gitlab_jws.path}";
      secretFile = "${config.sops.templates.gitlab_secret.path}";
      activeRecordDeterministicKeyFile = "${config.sops.templates.gitlab_activeRecordDeterministicKeyFile.path}";
      activeRecordPrimaryKeyFile = "${config.sops.templates.gitlab_activeRecordPrimaryKeyFile.path}";
      activeRecordSaltFile = "${config.sops.templates.gitlab_activeRecordSaltFile.path}";
      dbFile = "${config.sops.templates.gitlab_secret.path}";
    };
  };
  sops = {
    secrets = {
      "gitlab/db_password" = {};
      "gitlab/pass" = {};
      "gitlab/otp" = {};
      "gitlab/jws" = {};
      "gitlab/secret" = {};
      "gitlab/activeRecordDeterministicKeyFile" = {};
      "gitlab/activeRecordPrimaryKeyFile" = {};
      "gitlab/activeRecordSaltFile" = {};
    };

    templates = {
      gitlab_pass = {
        content = ''
          ${config.sops.placeholder."gitlab/pass"}
        '';
        owner = "gitlab";
      };
      gitlab_db = {
        content = ''
          ${config.sops.placeholder."gitlab/db_password"}
        '';
        owner = "gitlab";
      };
      gitlab_otp = {
        content = ''
          ${config.sops.placeholder."gitlab/otp"}
        '';
        owner = "gitlab";
      };
      gitlab_secret = {
        content = ''
          ${config.sops.placeholder."gitlab/secret"}
        '';
        owner = "gitlab";
      };
      gitlab_jws = {
        content = ''
          ${config.sops.placeholder."gitlab/jws"}
        '';
        owner = "gitlab";
      };
      gitlab_activeRecordDeterministicKeyFile = {
        content = ''
          ${config.sops.placeholder."gitlab/activeRecordDeterministicKeyFile"}
        '';
        owner = "gitlab";
      };
      gitlab_activeRecordPrimaryKeyFile = {
        content = ''
          ${config.sops.placeholder."gitlab/activeRecordPrimaryKeyFile"}
        '';
        owner = "gitlab";
      };
      gitlab_activeRecordSaltFile = {
        content = ''
          ${config.sops.placeholder."gitlab/activeRecordSaltFile"}
        '';
        owner = "gitlab";
      };
    };
  };
}
