{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.modules.programs.git;
in {
  options.modules.programs.git.enable = lib.mkEnableOption "git";
  config = lib.mkIf cfg.enable {
    home-manager.users.lorev = _: {
      programs = {
        git = {
          enable = true;
          signing.format = null;
          settings = {
            user = {
              name = "lorev";
              email = "lorenzopasqui@gmail.com";
            };
            credential.helper = "${
              pkgs.git.override {withLibsecret = true;}
            }/bin/git-credential-libsecret";
            push = {autoSetupRemote = true;};
          };
        };
        gitui = {
          enable = true;
          theme = ''
                  (
                move_left: Some(( code: Char('h'), modifiers: "")),
                move_right: Some(( code: Char('l'), modifiers: "")),
                move_up: Some(( code: Char('k'), modifiers: "")),
                move_down: Some(( code: Char('j'), modifiers: "")),

                stash_open: Some(( code: Char('l'), modifiers: "")),
                open_help: Some(( code: F(1), modifiers: "")),

                status_reset_item: Some(( code: Char('U'), modifiers: "SHIFT")),
            )
          '';
        };
      };
    };
  };
}
