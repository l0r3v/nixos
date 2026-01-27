{
  lib,
  config,
  ...
}: let
  cfg = config.modules.programs.kanata;
in {
  options.modules.programs.kanata = {
    enable = lib.mkEnableOption "Kanata Keyboard Remapper";

    devices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Lista dei path dei device (tastiere) da intercettare.";
      example = ["/dev/input/by-id/usb-Logitech_Keyboard-event-kbd"];
    };
  };

  config = lib.mkIf cfg.enable {
    services.kanata = {
      enable = true;
      keyboards = {
        internalKeyboard = {
          devices = cfg.devices;

          extraDefCfg = ''
            process-unmapped-keys yes
          '';

          config = ''
            (defsrc
             caps a s d f g h j k l ; F1 u i o z lalt
            )
            (deflocalkeys-linux
             < 86
            )
            (defvar
             tap-time 200
             hold-time 200
            )
            (defalias
             capsesc (tap-hold $tap-time $hold-time esc lctl)
             a-mod (tap-hold $tap-time $hold-time a ralt)
             s-mod (tap-hold $tap-time $hold-time s lctl)
             d-mod (tap-hold $tap-time $hold-time d lsft)
             f-mod (tap-hold $tap-time $hold-time f lmet)
             j-mod (tap-hold $tap-time $hold-time j rmet)
             k-mod (tap-hold $tap-time $hold-time k rsft)
             l-mod (tap-hold $tap-time $hold-time l rctl)
             ;-mod (tap-hold $tap-time $hold-time ; lalt)
             z-mod (tap-hold $tap-time $hold-time z <)

             mouse-control (tap-hold 200 200 F1 (layer-toggle mouse))

             to-game (layer-switch game)
             to-base (layer-switch base)

             f1-game (tap-hold 200 200 F1 (layer-toggle game-exit))

             mouse-left (movemouse-left 100 20)
             mouse-right (movemouse-right 100 20)
             mouse-up (movemouse-up 100 20)
             mouse-down (movemouse-down 100 20)
             click-left mltp
             click-right mrtp
             click-middle mmtp
            )

            (deflayer base
             @capsesc
             @a-mod
             @s-mod
             @d-mod
             @f-mod
             g
             h
             @j-mod
             @k-mod
             @l-mod
             @;-mod
             @mouse-control
             u
             i
             o
             @z-mod
             lalt
             )

            (deflayer mouse
             _ _ _ _ _ @to-game @mouse-left @mouse-down @mouse-up @mouse-right _ _ @click-left @click-middle @click-right _ _
            )

            (deflayer game
             esc a s d f g h j k l ; @f1-game u i o z lalt
            )

            (deflayer game-exit
             _ _ _ _ _ @to-base _ _ _ _ _ _ _ _ _ _ _
            )
          '';
        };
      };
    };
  };
}
