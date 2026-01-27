{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.modules.programs.waybar;
in {
  options.modules.programs.waybar = {
    enable = lib.mkEnableOption "Custom configuration of Waybar";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
    ];

    home-manager.users.lorev = {...}: {
      imports = [./waybar.nix];
    };
  };
}
