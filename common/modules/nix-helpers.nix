{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.nix-helpers;
in {
  options.modules.nix-helpers = {
    enable = lib.mkEnableOption "A suit of different nix related utils";
  };
  imports = [
    inputs.nixos-cli.nixosModules.nixos-cli
  ];
  config = lib.mkIf cfg.enable {
    nix = {
      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 3d";
      };
      optimise = {
        automatic = true;
        persistent = true;
        dates = "6:00";
      };
    };
    environment = {
      sessionVariables = {
        NH_FLAKE = "$HOME/nixos";
        FLAKE = "$HOME/nixos";
        NIXOS_CONFIG = "$HOME/nixos";
      };
      systemPackages = with pkgs; [
        inputs.optnix.packages."${pkgs.stdenv.hostPlatform.system}".optnix
        deploy-rs
        nh # nix-helper (wrapper per nixos-rebuild + gc + flake)
        nix-index # indicizza comandi nei pacchetti
        nix-tree # visualizza dipendenze di uno store path
        nix-du # mostra spazio occupato nello store
        statix # linter per codice nix
        deadnix # trova codice morto
        nix-init # inizializza package.nix
        devenv
        nvd
        nix-output-monitor
        nix-diff
      ];
    };
    programs = {
      nix-index = {
        enable = true; # auto run post-activation
        enableZshIntegration = false;
        enableBashIntegration = false;
      };
    };

    services.nixos-cli = {
      enable = true;
      config = {
        aliases = {
          list = ["generation" "list"];
          switch = ["generation" "switch"];
          rollback = ["generation" "rollback"];
          delete = ["generation" "delete"];
          clean = ["generation" "delete" "-k" "3"];
          build = ["apply" "--no-activate" "--no-boot" "--output" "result"];
          test = ["apply" "--no-boot" "--no-activate"];
        };
      };
    };
  };
}
