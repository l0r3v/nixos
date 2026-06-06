{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.modules.desktop.hyprland;
in {
  options.modules.desktop.hyprland = {
    enable = lib.mkEnableOption "hyprland";
    monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Hyprland monitor configuration strings, e.g. ['DP-3,1920x1080@60,0x0,1']";
    };
  };

  config = lib.mkIf cfg.enable {
    nix.settings = {
      substituters = [
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      package = inputs.hyprland.packages."${pkgs.stdenv.hostPlatform.system}".hyprland;
      portalPackage = inputs.hyprland.packages."${pkgs.stdenv.hostPlatform.system}".xdg-desktop-portal-hyprland;
    };

    environment.systemPackages = with pkgs; [
      fuzzel
    ];

    xdg.portal = {
      enable = true;
      config = {
        hyprland = {
          default = ["hyprland"];
        };
        common = {
          default = ["hyprland"];
        };
      };
    };

    home-manager.users.lorev = {
      pkgs,
      config,
      ...
    }: {
      home.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        MOZ_ENABLE_WAYLAND = "1";
        XDG_SESSION_TYPE = "wayland";
        XDG_CURRENT_DESKTOP = "Hyprland";
        XDG_SESSION_DESKTOP = "Hyprland";
      };

      wayland.windowManager.hyprland = {
        enable = true;
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
        systemd = {
          enable = true;
          enableXdgAutostart = true;
          variables = ["--all"];
        };
        settings = {
          general = {
            gaps_in = 6;
            gaps_out = 6;
            border_size = 2;
          };

          exec-once = config.modules.startup.programs;

          monitor = cfg.monitors;

          dwindle = {
            pseudotile = true;
            preserve_split = true;
          };

          decoration = {
            rounding = 12;
            rounding_power = 2;
            active_opacity = 1;
            inactive_opacity = 1;
            dim_inactive = false;
            dim_strength = 0.05;
            blur = {
              enabled = true;
              size = 1;
              passes = 6;
              new_optimizations = true;
              ignore_opacity = false;
              xray = false;
            };
            shadow = {
              enabled = true;
              range = 4;
              render_power = 3;
            };
          };

          animations = {
            enabled = false;
            bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
            animation = [
              "windows, 1, 7, myBezier"
              "windowsOut, 1, 7, default, popin 80%"
              "border, 1, 10, default"
              "borderangle, 1, 8, default"
              "fade, 1, 7, default"
              "workspaces, 1, 6, default"
            ];
          };

          misc = {
            disable_hyprland_logo = true;
          };

          input = {
            kb_layout = "it";
          };

          xwayland = {
            force_zero_scaling = true;
          };

          env = [
            "GTK_SCALE,2"
            "XCURSOR_SIZE,32"
          ];

          "$mainMod" = "SUPER";
          "$terminal" = "ghostty";
          "$menu" = "fuzzel";
          "$browser" = "zen";

          bind = [
            "$mainMod, Escape, exec, bash ~/.config/scripts/powermenu.sh"
            "$mainMod, Return, exec, $terminal"
            "$mainMod, Q, killactive"
            "$mainMod, E, exec, $browser"
            "$mainMod, Space, exec, $menu"
            "$mainMod, V, togglefloating"
            "$mainMod, P, pseudo"
            "$mainMod, F, fullscreen"

            # Focus navigation
            "$mainMod, H, movefocus, l"
            "$mainMod, L, movefocus, r"
            "$mainMod, K, movefocus, u"
            "$mainMod, J, movefocus, d"

            # Move windows
            "$mainMod SHIFT, H, movewindow, l"
            "$mainMod SHIFT, L, movewindow, r"
            "$mainMod SHIFT, K, movewindow, u"
            "$mainMod SHIFT, J, movewindow, d"

            # Workspaces 1-9
            "$mainMod, 1, workspace, 1"
            "$mainMod, 2, workspace, 2"
            "$mainMod, 3, workspace, 3"
            "$mainMod, 4, workspace, 4"
            "$mainMod, 5, workspace, 5"
            "$mainMod, 6, workspace, 6"
            "$mainMod, 7, workspace, 7"
            "$mainMod, 8, workspace, 8"
            "$mainMod, 9, workspace, 9"

            # Move window to workspace
            "$mainMod CTRL, 1, movetoworkspacesilent, 1"
            "$mainMod CTRL, 2, movetoworkspacesilent, 2"
            "$mainMod CTRL, 3, movetoworkspacesilent, 3"
            "$mainMod CTRL, 4, movetoworkspacesilent, 4"
            "$mainMod CTRL, 5, movetoworkspacesilent, 5"
            "$mainMod CTRL, 6, movetoworkspacesilent, 6"
            "$mainMod CTRL, 7, movetoworkspacesilent, 7"
            "$mainMod CTRL, 8, movetoworkspacesilent, 8"
            "$mainMod CTRL, 9, movetoworkspacesilent, 9"

            # Scroll through workspaces
            "$mainMod, mouse_down, workspace, e+1"
            "$mainMod, mouse_up, workspace, e-1"
            "$mainMod SHIFT, K, workspace, e+1"
            "$mainMod SHIFT, J, workspace, e-1"

            # Quit / power off monitor
            "$mainMod SHIFT, E, exit"
            "$mainMod SHIFT, P, exec, hyprctl dispatch dpms off"

            # Screenshots
            ", Print, exec, grim -g \"$(slurp)\""
            "CTRL, Print, exec, grim"

            # University shortcuts
            "Control_L&Alt_R, T, exec, $terminal -d ~/current_course"
            "Control_L&Alt_R, N, exec, $terminal -d ~/current_course --hold sh -c nvim"
            "Control_L&Alt_R, L, exec, rofi-lectures"
            "Control_L&Alt_R, C, exec, rofi-courses"
            "Control_L&Alt_R, V, exec, rofi-lectures-view"
            "Control_L&Alt_R, B, exec, backup-uni"
            "Control_L&Alt_R, S, exec, bash ~/university-setup/other/select_subfolder"
            "Control_L&Alt_R, P, exec, select_file-uni"
            "Control_L&Alt_R, Y, exec, select_file-uni rec"
            "Control_L&Alt_R, I, exec, bash ~/university-setup/other/scrsht_util.sh"

            # Bitwarden rofi
            "Control_L&SHIFT, L, exec, rofi-rbw --no-help --keybindings Ctrl+1:type:username,Ctrl+2:type:password,Ctrl+3:type:totp"
            "Control_L&SHIFT, A, exec, rofi-pulse-select sink"
          ];

          bindel = [
            ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"
            ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"
            ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
            ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
            ",XF86AudioPlay, exec, playerctl play-pause"
            ",XF86AudioStop, exec, playerctl stop"
            ",XF86AudioPrev, exec, playerctl previous"
            ",XF86AudioNext, exec, playerctl next"
            ",XF86MonBrightnessUp, exec, brightnessctl set 10%+"
            ",XF86MonBrightnessDown, exec, brightnessctl set 10%-"
          ];

          bindm = [
            "$mainMod, mouse:272, movewindow"
            "$mainMod, mouse:273, resizewindow"
          ];
        };
      };
    };
  };
}
