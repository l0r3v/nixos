{...}: {
  imports = [
    #./dawarich
    #./tududi
    #./gitea
    ./owncloud
    ./rdt-client
  ];
  virtualisation.docker.enable = true;
  users.users."hspasqui".extraGroups = ["docker"];
}
