{
  description = "NixOS configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:Iorev/nixvim-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix";

    hyprland.url = "github:hyprwm/Hyprland";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    inkscape-figures = {
      url = "github:Iorev/inkscape-figures";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    university-setup = {
      url = "github:Iorev/university-setup";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yt-x = {
      url = "github:Benexl/yt-x";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    alejandra = {
      url = "github:kamadorueda/alejandra";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homelab = {
      url = "path:/home/lorev/nixos-homelab";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {nixpkgs, ...} @ inputs: let
    system = "x86_64-linux";
    themeName = "mocha";
  in {
    formatter.${system} = inputs.alejandra.defaultPackage.${system};
    nixosConfigurations = {
      XPSnixos = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit system inputs themeName;};
        modules = [
          ./configuration.nix
          inputs.sops-nix.nixosModules.sops
          inputs.stylix.nixosModules.stylix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.lorev = import ./home.nix;
              extraSpecialArgs = {
                inherit system inputs themeName;
              };
            };
          }
        ];
      };

      homelab = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs themeName;};
        modules = [
          inputs.homelab.nixosModules.homelab
          inputs.sops-nix.nixosModules.sops
          inputs.stylix.nixosModules.stylix
        ];
      };

      iso = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./isoimage/configuration.nix
        ];
      };
    };
  };
}
