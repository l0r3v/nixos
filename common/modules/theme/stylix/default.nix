{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.modules.theme.stylix;
in {
  imports = [inputs.stylix.nixosModules.stylix];
  options.modules.theme.stylix = {
    enable = lib.mkEnableOption "Stylix Theme Engine";

    scheme = lib.mkOption {
      type = lib.types.either lib.types.path lib.types.attrs;
      description = "Schema colori Base16 (yaml file o attributi)";
      default = "${pkgs.base16-schemes}/share/themes/everforest-dark-soft.yaml";
    };

    polarity = lib.mkOption {
      type = lib.types.str;
      default = "dark";
    };
  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      base16Scheme = cfg.scheme;
      polarity = cfg.polarity;
      targets.qt.platform = lib.mkForce "qtct";

      image =
        pkgs.runCommand "nix-colored.png" {
          nativeBuildInputs = [pkgs.imagemagick];
        } ''
          convert -background "#${config.lib.stylix.colors.base00}" -flatten ${./nix-transp.png} $out
        '';

      opacity = {
        applications = 1.0;
        desktop = 0.85;
        popups = 0.85;
        terminal = 0.85;
      };

      cursor = {
        package = pkgs.whitesur-cursors;
        name = "WhiteSur-cursors";
        size = 24;
      };

      fonts = let
        font = {
          package = pkgs.julia-mono;
          name = "JuliaMono-Black";
        };
      in {
        serif = font;
        sansSerif = font;
        monospace = font;
      };
    };

    home-manager.users.lorev = {...}: {
    };
  };
}
