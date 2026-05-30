{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.programs.game-dev;
in {
  options.modules.programs.game-dev.enable = lib.mkEnableOption "game development tools";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.modules.programs.nixvim.enable;
        message = "modules.programs.game-dev requires modules.programs.nixvim to be enabled";
      }
    ];

    home-manager.users.lorev = _: {
      home.packages = with pkgs; [
        godot_4-mono
        blender
        dotnet-sdk
      ];
    };
  };
}
