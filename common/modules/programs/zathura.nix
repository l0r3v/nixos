{
  lib,
  config,
  ...
}: let
  cfg = config.modules.programs.zathura;
in {
  options.modules.programs.zathura = {
    enable = lib.mkEnableOption "Zathura PDF viewer";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.lorev = {...}: {
      programs.zathura = {
        enable = true;
        mappings = {
          "<C-l>" = "feedkeys :blist <Tab>";
          "<C-m>" = "feedkeys :bmark";
        };
        options = {
          recolor = true;
          #enable copy to clipboard
          selection-clipboard = "clipboard";
        };
      };
      xdg.mimeApps.defaultApplications = {
        "application/pdf" = "org.pwmt.zathura.desktop";
      };
    };
  };
}
