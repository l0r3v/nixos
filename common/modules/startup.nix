{ lib, config, ... }:
let
  sysStartup = config.modules.startup.programs;
in
{
  options.modules.startup.programs = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "List of programs to run at startup (Passed to Home Manager)";
  };

  # Usiamo mkIf per assicurarci che questa parte venga valutata SOLO SE
  # il modulo Home Manager è effettivamente caricato nel sistema.
  config = lib.mkIf (config ? home-manager) {
    home-manager.users.lorev = { lib, ... }: {
      options.modules.startup.programs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Internal startup programs list";
      };

      config.modules.startup.programs = sysStartup;
    };
  };
}