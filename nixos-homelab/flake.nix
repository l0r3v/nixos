{
  description = "Homelab config";

  inputs = {
    xpsnixos.url = "path:/home/lorev/nixos-config";
    nixpkgs.follows = "xpsnixos/nixpkgs";
  };

  outputs = {...}: {
    nixosModules.homelab = {...}: {
      imports = [./configuration.nix];
    };
  };
}
