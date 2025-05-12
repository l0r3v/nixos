{config, ...}: {
  programs.waybar = {
    enable = true;
    style = ''
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
          font-size:97%;
          }
         window#waybar {
             background-color: @bgcolor;
             color: @fgcolor ;
             transition-property: background-color;
             transition-duration: .5s;
             border-radius: 5px;
         }

         window#waybar.hidden {
             opacity: 0.1;
         }

         window#waybar.empty,
         window#waybar.empty #window {
             padding: 0px;
             border: 0px;
             background-color: transparent;
         }

         tooltip {
             background: #1e1e2e;
             opacity: 0.6;
             border-radius: 10px;
             border-width: 2px;
             border-style: solid;
             border-color: #11111b;
         }

         #workspaces button {
             background-color: transparent;
             color: @fgcolor;
             box-shadow: none;
         	text-shadow: none;
             padding: 0px;
             border-radius: 9px;
             padding-left: 4px;
             padding-right: 4px;
             animation: gradient_f 20s ease-in infinite;
             transition: all 0.5s cubic-bezier(.55,-0.68,.48,1.682);
         }

         #taskbar button.active,
         #workspaces button.active {
             background-color: transparent;
             color: @accent1;
             padding-left: 8px;
             padding-right: 8px;
             animation: gradient_f 20s ease-in infinite;
             transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.682);
         }

         #taskbar button:hover,
         #workspaces button:hover {
             background: rgba(0, 0, 0, 0.2);
         	color: @accent3;
             padding-left: 0px;
             padding-right: 0px;
             animation: gradient_f 20s ease-in infinite;
             transition: all 0.3s cubic-bezier(.55,-0.68,.48,1.682);
         }

         #workspaces button.focused {
             background-color: #bbccdd;
             color: @accent2;
             /* box-shadow: inset 0 -3px #ffffff; */
         }

         #workspaces button.urgent {
             background-color: #eb4d4b;
         }

         #mode {
             background-color: #64727D;
             border-bottom: 3px solid #ffffff;
         }

         #backlight,
         #backlight-slider,
         #battery,
         #bluetooth,
         #clock,
         #cpu,
         #disk,
         #idle_inhibitor,
         #keyboard-state,
         #memory,
         #mode,
         #mpris,
         network,
         #power-profiles-daemon,
         #pulseaudio,
         #pulseaudio-slider,
         #taskbar,
         #temperature,
         #tray,
         #window,
         #wireplumber,
         #workspaces,
         #custom-backlight,
         #custom-browser,
         #custom-cava_mviz,
         #custom-cycle_wall,
         #custom-file_manager,
         #custom-keybinds,
         #custom-keyboard,
         custom-light_dark,
         #custom-lock,
         #custom-hint,
         #custom-hypridle,
         #custom-menu,
         #custom-power_vertical,
         #custom-power,
         #custom-settings,
         #custom-spotify,
         #custom-swaync,
         #custom-tty,
         #custom-updater,
         custom-weather,
         custom-weather.clearNight,
         custom-weather.cloudyFoggyDay,
         custom-weather.cloudyFoggyNight,
         custom-weather.default,
         custom-weather.rainyDay,
         custom-weather.rainyNight,
         custom-weather.severe,
         custom-weather.showyIcyDay,
         custom-weather.snowyIcyNight,
         custom-weather.sunnyDay {
         	padding-top: 0px;
         	padding-bottom: 1px;
         	padding-right: 6px;
         	padding-left: 6px;
         }

         /* If workspaces is the leftmost module, omit left margin */
         .modules-left > widget:first-child > #workspaces {
         }

         /* If workspaces is the rightmost module, omit right margin */
         .modules-right > widget:last-child > #workspaces {
         }

         #clock {
             color: @accent2;
         }

         #custom-updater {
             color: #7287fd;
         }

         #battery {
             color: @accent5;
         }

         /* #battery.charging {
             color: #ffffff;
             background-color: #26A65B;
         } */

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

         #bluetooth {
             color: #1e66f5;
         }

         #network {
             color: @accent3;
         }

         #network.disconnected {
             color: @alert;
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
         #custom-hypridle,
         #idle_inhibitor {
         	color: #f9e2af;
             /*background-color: #2d3436;*/
         }

         /*-----Indicators----*/
         #custom-hypridle.notactive,
         #idle_inhibitor.activated {
         	color: #39FF14;
         }

         #mpd {
             color: #2a5c45;
         }

         #mpd.disconnected {
             background-color: #f53c3c;
         }

         #mpd.stopped {
             background-color: #90b1b1;
         }

         #mpd.paused {
             background-color: #51a37a;
         }

         #custom-language {
             color: @accent5;
             min-width: 16px;
         }

         #custom-separator {
             color: #606060;
         }
         #pulseaudio-slider slider {
         	min-width: 0px;
         	min-height: 0px;
         	opacity: 0;
         	background-image: none;
         	border: none;
         	box-shadow: none;
         }

         #pulseaudio-slider trough {
         	min-width: 80px;
         	min-height: 5px;
         	border-radius: 5px;
         }

         #pulseaudio-slider highlight {
         	min-height: 10px;
         	border-radius: 5px;
         }

         #backlight-slider slider {
         	min-width: 0px;
         	min-height: 0px;
         	opacity: 0;
         	background-image: none;
         	border: none;
         	box-shadow: none;
         }

         #backlight-slider trough {
         	min-width: 80px;
         	min-height: 10px;
         	border-radius: 5px;
         }

         #backlight-slider highlight {
         	min-width: 10px;
         	border-radius: 5px;
         }

    '';
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        #exclusive = true;
        passthrough = false;
        gtk-layer-shell = true;
        margin-left = 6;
        margin-right = 6;
        margin-top = 1;

        modules-left = [
          #"idle_inhibitor"
          "group/mobo_drawer"
          "hyprland/workspaces#rw"
        ];

        modules-center = [
          "clock#2"
        ];

        modules-right = [
          "custom/file-text"
          "battery"
          "custom/battery-mode"
          "pulseaudio#1"
          "tray"
        ];
        "hyprland/workspaces" = {
          active-only = false;
          "all-outputs" = true;
          "format" = "{icon}";
          "show-special" = false;
          "on-click" = "activate";
          "on-scroll-up" = "hyprctl dispatch workspace e+1";
          "on-scroll-down" = "hyprctl dispatch workspace e-1";
          "persistent-workspaces" = {
            "*" = 5;
          };
          "format-icons" = {
            "active" = "";
            "default" = "";
          };
        };
        # NUMBERS and ICONS style with window rewrite
        "hyprland/workspaces#rw" = {
          "disable-scroll" = true;
          "all-outputs" = true;
          "warp-on-scroll" = false;
          "sort-by-number" = true;
          "show-special" = false;
          "on-click" = "activate";
          "on-scroll-up" = "hyprctl dispatch workspace e+1";
          "on-scroll-down" = "hyprctl dispatch workspace e-1";
          "format" = "{icon} {windows}";
          "format-window-separator" = " ";
          "window-rewrite-default" = " ";
          "window-rewrite" = {
            "title<.*youtube.*>" = " ";
            "title<.*amazon.*>" = " ";
            "title<.*reddit.*>" = " ";
            "title<.*Picture-in-Picture.*>" = " ";
            "class<firefox|org.mozilla.firefox|librewolf|floorp|mercury-browser>" = " ";
            "class<kitty|konsole|alacritty>" = " ";
            "class<kitty-dropterm>" = " ";
            "class<Chromium|Thorium>" = " ";
            "class<org.telegram.desktop|io.github.tdesktop_x64.TDesktop>" = " ";
            "class<[Ss]potify>" = " ";
            "class<VSCode|code-url-handler|code-oss|codium|codium-url-handler|VSCodium>" = "󰨞 ";
            "class<thunar>" = "󰝰 ";
            "class<org.pwmt.zathura>" = " ";
            "class<com.stremio.stremio>" = " ";
            "class<[Tt]hunderbird|[Tt]hunderbird-esr>" = " ";
            "class<discord|[Ww]ebcord|Vesktop>" = " ";
            "class<subl>" = "󰅳 ";
            "class<mpv>" = " ";
            "class<celluloid|Zoom>" = " ";
            "class<Cider>" = "󰎆 ";
            "class<virt-manager>" = " ";
            "class<codeblocks>" = "󰅩 ";
            "class<mousepad>" = " ";
            "class<libreoffice-writer>" = " ";
            "class<libreoffice-startcenter>" = "󰏆 ";
            "class<com.obsproject.Studio>" = " ";
            "class<polkit-gnome-authentication-agent-1>" = "󰒃 ";
            "class<nwg-look>" = " ";
            "class<zen-alpha>" = "󰰷 ";
            "class<waterfox|waterfox-bin>" = " ";
            "class<microsoft-edge>" = " ";
            "class<vlc>" = "󰕼 ";
          };
        };

        "group/mobo_drawer" = {
          "orientation" = "inherit";
          "drawer" = {
            "transition-duration" = 500;
            "children-class" = "cpu";
            "transition-left-to-right" = true;
          };
          "modules" = [
            "temperature"
            "cpu"
            "memory"
            "disk"
          ];
        };

        "cpu" = {
          "format" = "{usage}% 󰍛";
          "interval" = 1;
          "min-length" = 5;
          "format-alt-click" = "click";
          "format-alt" = "{icon0}{icon1}{icon2}{icon3} {usage:>2}% 󰍛";
          "format-icons" = [
            "▁"
            "▂"
            "▃"
            "▄"
            "▅"
            "▆"
            "▇"
            "█"
          ];
          #"on-click-right" = "gnome-system-monitor";
        };
        "disk" = {
          "interval" = 30;
          "path" = "/";
          "format" = "{percentage_used}% 󰋊";
          "tooltip-format" = "{used} used out of {total} on {path} ({percentage_used}%)";
        };

        "memory" = {
          "interval" = 10;
          #"format" = "{used=0.1f}G 󰾆";
          "format" = "{percentage}% 󰾆";
          #"format-alt-click" = "click";
          "tooltip" = true;
          #"tooltip-format" = "{used=0.1f}GB/ {total=0.1f}G";
        };

        "temperature" = {
          "interval" = 10;
          "tooltip" = true;
          "hwmon-path" = [
            "/sys/class/hwmon/hwmon1/temp1_input"
            "/sys/class/thermal/thermal_zone0/temp"
          ];
          "critical-threshold" = 82;
          "format-critical" = "{temperatureC}°C {icon}";
          "format" = "{temperatureC}°C {icon}";
          "format-icons" = [
            "󰈸"
          ];
        };
        "idle_inhibitor" = {
          "tooltip" = true;
          "tooltip-format-activated" = "Idle_inhibitor active";
          "tooltip-format-deactivated" = "Idle_inhibitor not active";
          "format" = "{icon}";
          "format-icons" = {
            "activated" = " ";
            "deactivated" = " ";
          };
        };
        "clock#2" = {
          "format" = "  {:%H:%M}"; # 24H
          "format-alt" = "{:%A  |  %H:%M  |  %e %B}";
          "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };
        "tray" = {
          "icon-size" = 20;
          "spacing" = 4;
        };
        "pulseaudio#1" = {
          "format" = "{icon} {volume}%";
          "format-bluetooth" = "{icon}  {volume}%";
          "format-bluetooth-muted" = "  {icon}";
          "format-muted" = "󰸈";
          "format-icons" = {
            "headphone" = "󱡏 ";
            "hands-free" = " ";
            "headset" = "󰋎 ";
            "phone" = "";
            "portable" = "";
            "car" = "";
            "default" = [" " " " " "];
          };
          "on-click" = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "on-click-right" = "pavucontrol -t 3";
          "tooltip" = true;
          "tooltip-format" = "{icon} {desc} | {volume}%";
        };
        "battery" = {
          "align" = 0;
          "rotate" = 0;
          "full-at" = 100;
          "design-capacity" = false;
          "states" = {
            "good" = 95;
            "warning" = 30;
            "critical" = 15;
          };
          "format" = "{icon} {capacity}%";
          "format-charging" = " {capacity}%";
          "format-plugged" = "󱘖 {capacity}%";
          "format-alt-click" = "click";
          "format-full" = "{icon} Full";
          "format-alt" = "{icon} {time}";
          "format-icons" = [
            "󰂎"
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          "format-time" = "{H}h {M}min";
          "tooltip" = true;
          "tooltip-format" = "{timeTo} {power}w";
        };

        "custom/battery-mode" = {
          "exec" = "bash ~/.config/waybar/get_powermode.sh";
          "interval" = 10;
          "format" = "{}";
          "on-click" = "bash ~/.config/waybar/set_powermode.sh &6 bash ~/.config/waybar/get_powermode.sh";
          "return-type" = " text ";
        };
        "custom/file-text" = {
          "exec" = "bash ~/.config/waybar/watch_course.sh";
          "interval" = 5;
          "format" = "{}";
          "return-type" = "text ";
        };
      };
    };
  };
}
