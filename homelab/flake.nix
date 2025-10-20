{
  description = "Homelab Configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixvim = {
      url = "github:l0r3v/nixvim";
    };
    nixos-cli.url = "github:nix-community/nixos-cli";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    alejandra = {
      url = "github:kamadorueda/alejandra";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    optnix.url = "github:water-sucks/optnix";
  };

  outputs = {nixpkgs, ...} @ inputs: let
    system = "x86_64-linux";
  in {
    formatter.${system} = inputs.alejandra.defaultPackage.${system};
    nixosConfigurations = {
      homelab = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          inputs.sops-nix.nixosModules.sops
          ./configuration.nix
        ];
      };
    };
  };
}
