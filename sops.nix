{inputs, ...}: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  #SOPS
  sops = {
    defaultSopsFile = ./secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/lorev/.config/sops/age/keys.txt";
    secrets = {
      #  factorio_token = {
      #    owner = "lorev.name";
      #    group = "lorev.group";
      #  };
    };
  };
}
