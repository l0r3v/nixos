{...}: {
  imports = [
    #./dawarich
    #./tududi
    #./gitea
    ./owncloud
    ./sparkyfitness
    ./soulsync
    ./slskd
  ];
  virtualisation.docker.enable = true;
  users.users."hspasqui".extraGroups = ["docker"];
}
