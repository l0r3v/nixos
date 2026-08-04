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
      url = "git+https://forge.pasqui.casa/lorev/nixvim";
    };

    stylix = {
      url = "github:nix-community/stylix/pull/2337/head";
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
      url = "git+https://forge.pasqui.casa/lorev/university-setup";
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
    nixvirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/0.6.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hermes-webui = {
      url = "github:dbeley/hermes-webui-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.llm-agents.follows = "nixpkgs";
    };
    sparkyfitness = {
      url = "github:CodeWithCJ/SparkyFitness";
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
          inputs.nixvirt.nixosModules.default
          inputs.hermes-agent.nixosModules.default
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
