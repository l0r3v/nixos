{
  config,
  lib,
  ...
}: {
  options.homelab.tunnelRoutes = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {};
    description = "Cloudflare tunnel ingress routes contributed by service modules";
  };

  config = {
    sops = {
      secrets = {
        "cloudflared/json/AccountTag" = {};
        "cloudflared/json/TunnelSecret" = {};
        "cloudflared/json/TunnelID" = {};
        "cloudflared/cert" = {};
      };
      templates = {
        "cloudflared-cert.pem".content = ''
          ${config.sops.placeholder."cloudflared/cert"}
        '';
        "cloudflared-uuidjson".content = ''
          {"AccountTag":"${config.sops.placeholder."cloudflared/json/AccountTag"}","TunnelSecret":"${config.sops.placeholder."cloudflared/json/TunnelSecret"}","TunnelID":"${config.sops.placeholder."cloudflared/json/TunnelID"}","Endpoint":""}
        '';
      };
    };

    services.cloudflared = {
      enable = true;
      certificateFile = config.sops.templates."cloudflared-cert.pem".path;
      tunnels."homelab" = {
        credentialsFile = config.sops.templates."cloudflared-uuidjson".path;
        default = "http_status:404";
        ingress =
          config.homelab.tunnelRoutes
          // {
            "chessdriller.pasqui.casa" = "http://localhost:3123";
            "immich-swipe.pasqui.casa" = "http://localhost:4040";
          };
      };
    };
  };
}
