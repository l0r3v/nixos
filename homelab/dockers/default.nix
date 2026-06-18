{...}: {
  imports = [
    #./dawarich
    #./tududi
    #./gitea
    ./flaresolverr
    ./owncloud
    ./rdt-client
    ./soulsync
    ./slskd
  ];
  virtualisation.docker.enable = true;
  users.users."hspasqui".extraGroups = ["docker"];
}
