{
  lib,
  config,
  ...
}: let
  betterTransition = "all 0.3s cubic-bezier(.55,-0.68,.48,1.682)";
in {
  programs.waybar.style = ''
    @define-color fgcolor #${config.lib.stylix.colors.base06};  /* foreground color */
    @define-color bgcolor #${config.lib.stylix.colors.base00};  /* background color */
    @define-color light_green #${config.lib.stylix.colors.base0C}; /* light green*/
    @define-color blue #${config.lib.stylix.colors.base0B}; /* blue */
    @define-color sand #${config.lib.stylix.colors.base09}; /* sand */
    @define-color red #${config.lib.stylix.colors.base0E}; /* red*/
    @define-color mid_gray #${config.lib.stylix.colors.base05}; /* mid gray*/
    @define-color dark_gold #${config.lib.stylix.colors.base0F}; /* dark gold */

       *{
        font-weight:bold;
        font-size:16px;
        }

        window#waybar {
          background: rgba(0,0,0,0);
        }

       tooltip {
           background: #1e1e2e;
           opacity: 0.6;
           border-radius: 10px;
           border-width: 2px;
           border-style: solid;
           border-color: #11111b;
       }



       #mode {
           background-color: @bgcolor;
           border-bottom: 3px solid #ffffff;
       }


        #clock {
          font-weight: bold;
          color: @fgcolor;
        }
       #battery {
           color: @red;
       }

       @keyframes blink {
           to {
               background-color: #ffffff;
               color: #333333;
           }
       }

       #battery.critical:not(.charging) {
           color: @critical;
           animation-name: blink;
           animation-duration: 0.5s;
           animation-timing-function: linear;
           animation-iteration-count: infinite;
           animation-direction: alternate;
       }

       label:focus {
           background-color: #000000;
       }

       #custom-menu{
           color: #FFFFFF;
           /*padding: 3px;*/
       }

       #memory {
           color: @sand;
       }

       #backlight {
           color: #cdd6f4;
       }


       #pulseaudio {
           color: @blue;
       }

       #pulseaudio-muted {
           color: @blue;
       }
       #wireplumber {
           color: @red;
       }

       #wireplumber-muted {
           color: @blue;
       }


       #disk {
           color: @mid_gray;
       }

       #custom-music.visible {
           color: @mid_gray;
           padding: 0 10px;
          }

  '';
}
