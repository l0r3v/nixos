{...}: {
  imports = [
    ./immich.nix
    ./miniflux.nix
    ./mealie.nix
    #./linkwarden.nix
    ./cloudflared.nix
    ./paperless.nix
    ./postgresql.nix
    ./authentik.nix
    ./navidrome.nix
    #./headscale.nix #non funziona senza ip pubblico
    ./davis.nix
    #./vaultwarden.nix questo funziona ma non ha senso fare il cambio se non funziona con sso, che è quello che volevo fare
    ../../common/zerotier.nix
  ];
}
