{config, ...}: {
  sops.secrets = {
    "immich/db_password" = {};
  };

  sops.templates."immich.env".content = ''
    DB_PASSWORD=${config.sops.placeholder."immich/db_password"}
    POSTGRES_PASSWORD=${config.sops.placeholder."immich/db_password"}
  '';
  services.nginx = {
    enable = true;
    virtualHosts."immich-cors" = {
      listen = [
        {
          addr = "127.0.0.1";
          port = 2285;
        }
      ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:2283";
        extraConfig = ''
          if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Allow-Methods' 'GET, PUT, POST, DELETE, OPTIONS' always;
            add_header 'Access-Control-Allow-Headers' 'X-Api-Key, User-Agent, Content-Type' always;
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain charset=UTF-8';
            add_header 'Content-Length' 0;
            return 204;
          }
          if ($request_method ~* '(GET|POST)') {
              add_header 'Access-Control-Allow-Origin' '*' always;
              add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
              add_header 'Access-Control-Allow-Headers' 'X-Api-Key, User-Agent, Content-Type' always;
              add_header 'Access-Control-Max-Age' 1728000;
          }
        '';
      };
    };
  };
  services.immich = {
    enable = true;
    port = 2283;
    host = "0.0.0.0";
    openFirewall = true;
    mediaLocation = "/srv/archive/immich/uploads";
    secretsFile = config.sops.templates."immich.env".path;
    environment = {
      TZ = "Europe/Rome";
    };
  };
}
