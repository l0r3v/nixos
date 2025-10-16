{
  pkgs,
  inputs,
  ...
}: {
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    systemd = {
      enable = true;
      enableXdgAutostart = true;
      variables = [ "--all" ];
    };
    settings = {
      general = {
        gaps_in = 2;
        gaps_out = 4;
        border_size = 2;
        layout = "dwindle";
      };
      exec-once = [
        "nm-applet --indicator"
        "waybar"
        "dunst"
        "blueman-applet"
        "gammastep-indicator -l 45.068371:7.683070"
        "hacompanion"
        "owncloud"
      ];
      monitor = [
        "eDP-1,preferred,auto,1.2"
        "DP-2,preferred,auto-right,auto"
      ];
      gesture = [
        "3, horizontal, workspace"
      ];
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
      decoration = {
        rounding = 10;
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
      misc = {disable_hyprland_logo = true;};

      input = {
        kb_layout = "it";
        #kb_options = "caps:swapescape";
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
      "$menu" = "rofi -show drun";
      "$browser" = "firefox";
      bind = [
        "$mainMod, Return, exec, $terminal"
        "$mainMod, Q, killactive"
        "$mainMod, M, exit"
        "$mainMod, E, exec, $browser"
        "$mainMod, Space, togglefloating"
        "$mainMod, R, exec, $menu"
        "$mainMod, P, pseudo"
        "$mainMod, V, togglesplit"

        # Move focus with mainMod + arrow keys
        "$mainMod, H, movefocus, l"
        "$mainMod, L, movefocus, r"
        "$mainMod, K, movefocus, u"
        "$mainMod, J, movefocus, d"

        # Switch workspaces with mainMod + [0-9]
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Example special workspace (scratchpad)
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"

        # Scroll through existing workspaces with mainMod + scroll
        "$mainMod SHIFT, K, workspace, e+1"
        "$mainMod SHIFT, J, workspace, e-1"
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
        "$mainMod, N, workspace, +1"
        "$mainMod SHIFT, N, movetoworkspace, +1"
        "$mainMod, B, workspace, -1"
        "$mainMod SHIFT, B, movetoworkspace, -1"

        "$mainMod, f, fullscreen"
        "$mainMod, c, exec, zathura ~/calendar"

        # University shortcuts
        "Control_L&Alt_R, t, exec, $terminal -d ~/current_course"
        "Control_L&Alt_R, n, exec, $terminal -d ~/current_course --hold sh -c nvim"
        "Control_L&Alt_R, l, exec, rofi-lectures"
        "Control_L&Alt_R, c, exec, rofi-courses"
        "Control_L&Alt_R, v, exec, rofi-lectures-view"
        "Control_L&Alt_R, b, exec, backup-uni"
        "Control_L&Alt_R, s, exec, bash ~/university-setup/other/select_subfolder"
        "Control_L&Alt_R, p, exec, select_file-uni"
        "Control_L&Alt_R, y, exec, select_file-uni rec"
        "Control_L&Alt_R, i, exec, bash ~/university-setup/other/scrsht_util.sh"

        "Control_L&Alt_R, w, exec, $browser -new-tab $(yq .link ~/current_course/info.yaml | tr -d '\"')"
        "Control_L&Alt_R, x, exec, $browser -new-tab $(yq .extra ~/current_course/info.yaml | tr -d '\"')"
        "Control_L&Alt_R, g, exec, $browser -new-tab $(yq .goodnotes ~/current_course/info.yaml | tr -d '\"')"

        #Bitwarden rofi
        "Control_L&SHIFT, l, exec,rofi-rbw --no-help --keybindings Ctrl+1:type:username,Ctrl+2:type:password,Ctrl+3:type:totp"
        "Control_L&SHIFT, a, exec,rofi-pulse-select sink"
      ];
      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle "
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl s 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl s 5%-"
      ];
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      bindl = [
        ", switch:Lid Switch, exec,bash ~/lid-monitor.sh"
      ];
    };
  };
}
