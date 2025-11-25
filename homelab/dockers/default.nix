{...}: {
  imports = [
    ./actual-budget
    ./calibre-web
    ./owncloud
    ./gitea
    #./portainer
    ./tududi
    ./authentik
    #./dawarich
  ];
  virtualisation.docker.enable = true;
  users.users."hspasqui".extraGroups = ["docker"];
}
