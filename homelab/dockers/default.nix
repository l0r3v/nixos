{...}: {
  imports = [
    #./dawarich
    #./tududi
    #./gitea
    ./flaresolverr
    ./owncloud
    ./rdt-client
  ];
  virtualisation.docker.enable = true;
  users.users."hspasqui".extraGroups = ["docker"];
}
