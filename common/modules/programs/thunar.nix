{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.modules.programs.thunar;
in {
  options.modules.programs.thunar = {
    enable = lib.mkEnableOption "Thunar file manager";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.thunar-archive-plugin
      pkgs.thunar-volman
      pkgs.thunar-vcs-plugin
    ];

    programs.thunar = {
      enable = true;
    };
    services.gvfs.enable = true; # Mount virtuali
    services.tumbler.enable = true; # Generazione anteprime immagini
  };
}
