{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.modules.programs.texlive;
  tex = pkgs.texliveSmall.withPackages (ps: [
    ps.scheme-small
    ps.collection-langitalian
    ps.latexmk
    ps.titlesec
    ps.titling
    ps.pgfplots
    ps.wrapfig
    ps.import
    ps.cancel
    ps.xifthen
    ps.transparent
    ps.cleveref
    ps.ifmtarg
    ps.l3packages
    ps.tcolorbox
    ps.adjustbox
    ps.physics
    ps.tikzfill
    ps.pdfcol
    ps.listingsutf8
    ps.xargs
  ]);
in {
  options.modules.programs.texlive.enable = lib.mkEnableOption "texlive";
  config = lib.mkIf cfg.enable {
    home-manager.users.lorev = _: {
      home.packages = [tex];
    };
  };
}
