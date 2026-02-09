{...}: {
  imports = [
    #./dawarich
    #./tududi
    ./actual-budget
    ./calibre-web
    ./gitea
    ./owncloud
  ];
  virtualisation.docker.enable = true;
  users.users."hspasqui".extraGroups = ["docker"];
}
