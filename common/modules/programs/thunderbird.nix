{
  lib,
  config,
  ...
}: let
  cfg = config.modules.programs.thunderbird;
in {
  options.modules.programs.thunderbird = {
    enable = lib.mkEnableOption "Enable thunderbird";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.lorev = _: {
      programs.thunderbird = {
        enable = true;
        profiles = {
          lorev = {
            isDefault = true;
          };
        };
      };
    };
  };
}
