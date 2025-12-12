{config, ...}: let
  keysPath =
    if config.networking.hostName == "XPSnixos"
    then "/home/lorev/.config/sops/age/keys.txt"
    else if config.networking.hostName == "homelab"
    then "/home/hspasqui/.config/sops/age/keys.txt"
    else if config.networking.hostName == "AMDnixos"
    then "/home/lorev/.config/sops/age/keys.txt"
    else "Error in hostname checking for sops-nix";
  sopsFiles = {
    "XPSnixos" = ../XPSnixos/secrets/secrets.yaml;
    "homelab" = ../homelab/secrets/secrets.yaml;
    "AMDnixos" = ../AMDnixos/secrets/secrets.yaml;
  };
  sopsFile = sopsFiles.${config.networking.hostName};
in {
  sops = {
    defaultSopsFile = sopsFile;
    defaultSopsFormat = "yaml";
    age.keyFile = keysPath;
  };
}
