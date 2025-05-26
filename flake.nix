{
  description = "NixOS configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixos-cli.url = "github:nix-community/nixos-cli";
    nixvim = {
      url = "git+ssh://git@git.pasqui.casa/lorev/nixvim";
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
  };

  outputs = {nixpkgs, ...} @ inputs: let
    system = "x86_64-linux";
    themeName = "sandcastle";
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
          inputs.nixos-hardware.nixosModules.dell-xps-15-9500
          inputs.nixos-cli.nixosModules.nixos-cli
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
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
          ./homelab/configuration.nix
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
