{...}: {
  imports = [
    #./dawarich
    #./tududi
    #./gitea
    ./owncloud
  ];
  virtualisation.docker.enable = true;
  users.users."hspasqui".extraGroups = ["docker"];
}
