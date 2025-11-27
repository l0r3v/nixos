{...}: {
  imports = [
    ./immich.nix
    ./miniflux.nix
    ./cloudflared.nix
    ./paperless.nix
    ./navidrome.nix
    #./headscale.nix #non funziona senza ip pubblico
    ./davis.nix
    ./vaultwarden.nix
    ../../common/zerotier.nix
  ];
}
