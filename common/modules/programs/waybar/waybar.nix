{...}: {
  imports = [
    ./style.nix
  ];
  home.file = {
    ".config/waybar/watch_course.sh".text = ''
      #! /usr/bin/env nix-shell
      #! nix-shell -i bash -p bash
            cat /tmp/current_course'';
    ".config/waybar/music.sh" = {
      source = ./scripts/music.sh;
      executable = true;
    };
  };
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        passthrough = false;
        gtk-layer-shell = true;
        margin-left = 6;
        margin-right = 6;
        margin-top = 1;

        modules-left = [
          #"idle_inhibitor"
          "group/mobo_drawer"
          #"hyprland/workspaces#rw"
        ];

        modules-center = [
          "clock"
          "custom/music"
        ];

        modules-right = [
          "custom/file-text"
          "battery"
          "custom/battery-mode"
          "pulseaudio#1"
          "tray"
        ];
        "hyprland/workspaces" = {
          "all-outputs" = true;
          "format" = "{icon}";
          "show-special" = false;
          "on-click" = "activate";
          "on-scroll-up" = "hyprctl dispatch workspace e+1";
          "on-scroll-down" = "hyprctl dispatch workspace e-1";
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
            "class<kitty|konsole|ghostty|alacritty>" = " ";
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
            "class<zen-alpha>" = "󰰷 ";
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
        "clock" = {
          "format" = "  {:L%H:%M}"; # 24H
          "format-alt" = "{:%A  |  %H:%M  |  %e %B}";
          tooltip-format = "<big>{:%A, %d.%B %Y }</big>\n<tt><small>{calendar}</small></tt>";
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

        "custom/file-text" = {
          "exec" = "bash ~/.config/waybar/watch_course.sh";
          "interval" = 5;
          "format" = "{}";
          "return-type" = "text ";
        };
        "custom/music" = {
          "format" = "{}";
          "return-type" = "json";
          "interval" = 3;
          "exec" = "~/.config/waybar/music.sh";
          "on-click" = "playerctl play-pause";
          "on-click-right" = "playerctl next";
          "on-click-middle" = "playerctl previous";
          "on-scroll-up" = "playerctl volume 0.05+";
          "on-scroll-down" = "playerctl volume 0.05-";
          "tooltip" = false;
        };
      };
    };
  };
}
