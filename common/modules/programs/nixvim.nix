{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.modules.programs.nixvim;
in {
  options.modules.programs.nixvim = {
    enable = lib.mkEnableOption "NixVim (Custom Flake + Stylix)";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.lorev = {
      pkgs,
      config,
      ...
    }: let
      inherit (pkgs.stdenv.hostPlatform) system;

      nixvim-package = inputs.nixvim.packages.${system}.full;

      extended-nixvim = nixvim-package.extend config.stylix.targets.nixvim.exportedModule;
    in {
      home.packages = [
        extended-nixvim
      ];

      home.sessionVariables = {
        EDITOR = "nvim";
      };
    };
  };
}
