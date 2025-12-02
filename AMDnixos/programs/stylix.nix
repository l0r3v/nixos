{pkgs, ...}: let
  themeName = "espresso";
  wallpaper-wing = ../dotfiles/wallpaper/wingInFlux.jpg;
  macchiato = ../dotfiles/wallpaper/nixos-wallpaper-catppuccin-mocha.png;
  inputImage = ../dotfiles/wallpaper/nix-transp.png;
  # https://tinted-theming.github.io/tinted-gallery/
  theme = "${pkgs.base16-schemes}/share/themes/${themeName}.yaml";
  wallpaper-nix = pkgs.runCommand "nix-colored.png" {} ''
    COLOR=$(${pkgs.yq}/bin/yq -r .palette.base00 ${theme})
    ${pkgs.imagemagick}/bin/convert -background $COLOR -flatten ${inputImage} $out
  '';
in {
  stylix = {
    enable = true;
    base16Scheme = theme;
    image = wallpaper-nix;
    opacity = {
      applications = 1.0; #This doesn't seem to work
      desktop = 0.85;
      popups = 0.85;
      terminal = 0.85;
    };
    polarity = "dark";

    cursor = {
      package = pkgs.whitesur-cursors;
      name = "WhiteSur-cursors";
      size = 1;
    };
    fonts = {
      serif = {
        package = pkgs.fira-sans;
        name = "FiraSans";
      };
      sansSerif = {
        package = pkgs.fira-sans;
        name = "FiraSans";
      };
      monospace = {
        package = pkgs.fira-mono;
        name = "Fira Code nerd font mono";
      };
    };
  };
}
