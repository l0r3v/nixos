{...}: {
  imports = [
    #./dawarich
    #./portainer
    #./tududi
    ./actual-budget
    ./authentik
    ./calibre-web
    ./gitea
    ./owncloud
  ];
  virtualisation.docker.enable = true;
  users.users."hspasqui".extraGroups = ["docker"];
}
