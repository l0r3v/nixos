{
  config,
  lib,
  pkgs,
  ...
}: let
  port = 5000;
in {
  # Route books.pasqui.casa → Kavita
  homelab.tunnelRoutes = {
    "books.pasqui.casa" = "http://localhost:${toString port}";
  };

  sops.secrets."kavita/tokenKey" = {
    owner = "kavita";
    group = "kavita";
    mode = "0400";
  };

  sops.secrets."kavita/oidcSecret" = {
    owner = "kavita";
    group = "kavita";
    mode = "0400";
  };

  services.kavita = {
    enable = true;
    user = "kavita";
    dataDir = "/var/lib/kavita";
    tokenKeyFile = config.sops.secrets."kavita/tokenKey".path;
    settings = {
      Port = port;
      IpAddresses = "127.0.0.1";
      OpenIdConnectSettings = {
        Authority = "https://auth.pasqui.casa/application/o/kavita/";
        ClientId = "kavita";
        Secret = "@OIDC_SECRET@";
        CustomScopes = ["openid" "profile" "email"];
      };
    };
  };
  # Assicura che la directory dei dati esista (il modulo NixOS le crea già,
  # ma le aggiungiamo per sicurezza)
  systemd.tmpfiles.rules = [
    "d '/var/lib/kavita' 0750 kavita kavita - -"
    "d '/var/lib/kavita/config' 0750 kavita kavita - -"
  ];

  # Aggiunge l'utente kavita al gruppo media per leggere i libri
  users.users.kavita = {
    isSystemUser = true;
    group = "kavita";
    extraGroups = ["media"];
  };
  users.groups.kavita = {};

  # Crea la directory config PRIMA che il modulo NixOS scriva appsettings.json
  systemd.services.kavita.preStart = lib.mkBefore ''
    mkdir -p /var/lib/kavita/config
  '';
  # Sostituisce @OIDC_SECRET@ DOPO che il modulo ha scritto appsettings.json
  systemd.services.kavita.serviceConfig.ExecStartPre = lib.mkAfter [
    "+${pkgs.writeShellScript "kavita-replace-oidc" ''
      ${pkgs.replace-secret}/bin/replace-secret '@OIDC_SECRET@' \
        '${config.sops.secrets."kavita/oidcSecret".path}' \
        '${config.services.kavita.dataDir}/config/appsettings.json'
    ''}"
  ];
}
