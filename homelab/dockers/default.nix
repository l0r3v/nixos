{ ...}: {
  imports = [
    ./actual-budget
    ./immich-docker
    ./miniflux
    ./calibre-web
    ./owncloud
    ./gitea
    ./portainer
    ./cloudflared
  ];
  virtualisation.docker.enable = true;
  users.users."hspasqui".extraGroups = ["docker"];
}
