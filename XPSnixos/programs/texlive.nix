{pkgs, ...}: let
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
      ;
  };
in {
  # home-manager
  home.packages = with pkgs; [
    tex
  ];
}
