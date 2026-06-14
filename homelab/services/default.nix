{...}: {
  imports = [
    #./headscale.nix #non funziona senza ip pubblico
    #./linkwarden.nix
    #./vaultwarden.nix questo funziona ma non ha senso fare il cambio se non funziona con sso, che è quello che volevo fare
    ../../common/zerotier.nix
    ./actual-budget.nix
    ./authentik.nix
    ./caddy.nix
    ./calibre-web.nix
    ./cloudflared.nix
    ./davis.nix
    ./fisicatecnica-wiki.nix
    ./forgejo.nix
    ./hermes-agent.nix
    ./immich.nix
    ./lidarr.nix
    ./mealie.nix
    ./miniflux.nix
    ./navidrome.nix
    #./ntfy.nix
    ./paperless.nix
    ./postgresql.nix
    ./prowlarr.nix
    ./wyoming.nix
  ];
}
