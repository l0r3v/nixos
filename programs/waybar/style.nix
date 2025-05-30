{
  lib,
  config,
  ...
}: let
  betterTransition = "all 0.3s cubic-bezier(.55,-0.68,.48,1.682)";
in {
  programs.waybar.style = ''
    @define-color fgcolor #${config.lib.stylix.colors.base05};  /* foreground color */
    @define-color bgcolor #${config.lib.stylix.colors.base00};  /* background color */
    @define-color accent1 #${config.lib.stylix.colors.base0C}; /* light blue*/
    @define-color accent2 #${config.lib.stylix.colors.base0B}; /* green*/
    @define-color accent3 #${config.lib.stylix.colors.base09}; /* orange*/
    @define-color accent4 #${config.lib.stylix.colors.base0E}; /* purple*/
    @define-color accent5 #${config.lib.stylix.colors.base0D}; /* blue */
    @define-color accent6 #${config.lib.stylix.colors.base0F}; /* gray blue*/

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
           color: @accent5;
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

       #custom-keyboard,
       #cpu {
           color: @accent1;
       }

       #memory {
           color: @accent3;
       }

       #backlight {
           color: #cdd6f4;
       }


       #pulseaudio {
           color: @accent4;
       }

       #pulseaudio-muted {
           color: @accent2;
       }
       #wireplumber {
           color: @accent4;
       }

       #wireplumber-muted {
           color: @accent2;
       }


       #disk {
           color: @accent5;
       }

       #custom-separator {
           color: #606060;
       }
       #custom-music.visible {
           color: @accent4;
           padding: 0 10px;
          }

  '';
}
