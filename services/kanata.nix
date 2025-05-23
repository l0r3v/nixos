{...}: {
  services.kanata = {
    enable = true;
    keyboards = {
      internalKeyboard = {
        extraDefCfg = ''
          process-unmapped-keys yes
        '';
        config = ''


          (defsrc
           caps a s d f g h j k l ; F1 u i o z 
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
           ;-mod (tap-hold $tap-time $hold-time ; ralt)
           z-mod (tap-hold $tap-time $hold-time z <)

           mouse-control (layer-while-held mouse)
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
           )
          (deflayer mouse
           _
           _
           _
           _
           _
           _
           @mouse-left
           @mouse-down
           @mouse-up
           @mouse-right
           _
           _
           @click-left
           @click-middle
           @click-right
           _
           )
        '';
      };
    };
  };
}
