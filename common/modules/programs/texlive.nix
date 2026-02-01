{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.modules.programs.texlive;
  tex = pkgs.texlive.combine {
    inherit
      (pkgs.texlive)
      scheme-small
      collection-langitalian
      latexmk
      titlesec
      titling
      pgfplots
      wrapfig
      import
      cancel
      xifthen
      transparent
      cleveref
      ifmtarg
      l3packages
      tcolorbox
      adjustbox
      physics
      tikzfill
      pdfcol
      listingsutf8
      xargs
      ;
  };
in {
  options.modules.programs.texlive.enable = lib.mkEnableOption "texlive";
  config = lib.mkIf cfg.enable {
    home-manager.users.lorev = _: {
      home.packages = [tex];
    };
  };
}
