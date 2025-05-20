{config, ...}: {
  sops.secrets = {
    "cloudflared/json/AccountTag" = {};
    "cloudflared/json/TunnelSecret" = {};
    "cloudflared/json/TunnelID" = {};
    "cloudflared/json/Endpoint" = {};
    "cloudflared/cert" = {};
  };
  sops.templates."cloudflared-cert.pem".content = ''
    ${config.sops.placeholder."cloudflared/cert"}
  '';
  sops.templates."cloudflared-uuidjson".content = ''
    {"AccountTag":"${config.sops.placeholder."cloudflared/json/AccountTag"}","TunnelSecret":"${config.sops.placeholder."cloudflared/json/TunnelSecret"}","TunnelID":"${config.sops.placeholder."cloudflared/json/TunnelID"}","Endpoint":""}
  '';

  services.cloudflared = {
    enable = true;
    certificateFile = config.sops.templates."cloudflared-cert.pem".path;
    tunnels = {
      "7a8e42ca-e4f4-4777-9146-c207582a8258" = {
        credentialsFile = config.sops.templates."cloudflared-uuidjson".path;
        default = "http_status:404";
      };
    };
  };
}
