{...}: {
  imports = [
    ./actual-budget
    #./immich-docker
    #./miniflux
    ./calibre-web
    ./owncloud
    ./gitea
    ./portainer
    #./cloudflared
    ./authentik
  ];
  virtualisation.docker.enable = true;
  users.users."hspasqui".extraGroups = ["docker"];
}
