{
  description = "Unified NixOS Configuration for AMDnixos, XPSnixos, and homelab";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixos-cli.url = "github:nix-community/nixos-cli";

    nixvim = {
      url = "github:l0r3v/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    inkscape-figures = {
      url = "github:l0r3v/inkscape-figures";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    university-setup = {
      url = "github:l0r3v/university-setup";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yt-x = {
      url = "github:Benexl/yt-x";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra = {
      url = "github:kamadorueda/alejandra";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    optnix = {
      url = "github:water-sucks/optnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri.url = "github:sodiboo/niri-flake";

    authentik-nix = {
      url = "github:nix-community/authentik-nix";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    deploy-rs,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    # Function to construct deploy nodes easier
    mkDeployNode = hostname: configName: {
      inherit hostname;
      profiles.system = {
        user = "root";
        sshUser = "nixos-builder";
        path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.${configName};
      };
    };
  in {
    formatter.${system} = inputs.alejandra.defaultPackage.${system};

    nixosConfigurations = {
      AMDnixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs system;};
        modules = [
          ./AMDnixos/configuration.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              backupFileExtension = "backup";
              users.lorev = import ./AMDnixos/home.nix;
              extraSpecialArgs = {inherit inputs system;};
            };
          }
        ];
      };

      XPSnixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs system;};
        modules = [
          ./XPSnixos/configuration.nix
          inputs.home-manager.nixosModules.home-manager
          inputs.nixos-hardware.nixosModules.dell-xps-15-9500-nvidia
          inputs.sops-nix.nixosModules.sops
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              users.lorev = import ./XPSnixos/home.nix;
              extraSpecialArgs = {inherit inputs system;};
            };
          }
        ];
      };

      homelab = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [
          inputs.sops-nix.nixosModules.sops
          inputs.authentik-nix.nixosModules.default
          ./homelab/configuration.nix
        ];
      };
    };

    deploy.nodes = {
      AMDnixos = mkDeployNode "AMDnixos" "AMDnixos";
      XPSnixos = mkDeployNode "XPSnixos" "XPSnixos";
      homelab = mkDeployNode "homelab" "homelab";
    };

    # Checks for deploy-rs to allow `nix flake check`
    checks = builtins.mapAttrs (_system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
