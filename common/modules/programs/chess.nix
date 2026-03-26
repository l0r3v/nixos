{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.modules.programs.chess;
in {
  options.modules.programs.chess.enable = lib.mkEnableOption "chess";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      scid
      en-croissant
      pawn-appetit
      stockfish
      chessx
      chessdb
    ];
    home-manager.users.lorev = _: {
    };
  };
}
