{config, ...}: {
  sops.secrets = {
    "davis/adminPass" = {};
    "davis/appPass" = {};
  };

  sops.templates."davis-adminpass".content = ''
    ${config.sops.placeholder."davis/adminPass"}
  '';

  sops.templates."davis-apppass".content = ''
    ${config.sops.placeholder."davis/appPass"}
  '';
  services.davis = {
    enable = true;
    adminLogin = "lorev";
    hostname = "cal.pasqui.casa";
    dataDir = "/srv/archive/davis";
    adminPasswordFile = config.sops.templates."davis-adminpass".path;
    appSecretFile = config.sops.templates."davis-apppass".path;
  };
}
