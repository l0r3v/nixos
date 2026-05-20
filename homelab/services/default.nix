{...}: {
  imports = [
    #./headscale.nix #non funziona senza ip pubblico
    #./linkwarden.nix
    #./vaultwarden.nix questo funziona ma non ha senso fare il cambio se non funziona con sso, che è quello che volevo fare
    ../../common/zerotier.nix
    ./authentik.nix
    ./cloudflared.nix
    ./davis.nix
    ./forgejo.nix
    ./immich.nix
    ./mealie.nix
    ./miniflux.nix
    ./navidrome.nix
    ./paperless.nix
    ./postgresql.nix
  ];
}
