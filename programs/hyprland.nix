{
  pkgs,
  inputs,
  ...
}: {
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    settings = {
      general = {
        gaps_in = 1;
        gaps_out = 2;
        border_size = 1;
        #"col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        #"col.inactive_border" = "rgba(595959aa)";
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
        "bitwarden"
      ];
      monitor = [
        "eDP-1,preferred,auto,1.25"
        "DP-2,preferred,auto-right,1.6"
      ];
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
      decoration = {
        rounding = 5;
        "active_opacity" = 1;
        "inactive_opacity" = 0.75;
        blur = {
          enabled = true;
          size = 8;
          passes = 5;
          vibrancy = 0.75;
        };
      };
      animations = {
        enabled = true;
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
        kb_options = "caps:swapescape";
      };
      gestures = {
        workspace_swipe = true;
      };
      xwayland = {
        force_zero_scaling = true;
      };
      env = [
        "GTK_SCALE,2"
        "XCURSOR_SIZE,32"
      ];
      "$mainMod" = "SUPER";
      "$terminal" = "alacritty";
      "$menu" = "rofi -show drun";
      "$browser" = "floorp";
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
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"

        "$mainMod, f, fullscreen"

        # University shortcuts
        "Control_L&Alt_L, t, exec, $terminal -d ~/current_course"
        "Control_L&Alt_L, n, exec, $terminal -d ~/current_course --hold sh -c nvim"
        "Control_L&Alt_L, l, exec, rofi-lectures"
        "Control_L&Alt_L, c, exec, rofi-courses"
        "Control_L&Alt_L, v, exec, rofi-lectures-view"
        "Control_L&Alt_L, b, exec, backup-uni"
        "Control_L&Alt_L, s, exec, bash ~/university-setup/other/select_subfolder"
        "Control_L&Alt_L, p, exec, select_file-uni"
        "Control_L&Alt_L, y, exec, select_file-uni rec"
        "Control_L&Alt_L, i, exec, bash ~/university-setup/other/scrsht_util.sh"

        "Control_L&Alt_L, w, exec, $browser -new-tab $(yq .link ~/current_course/info.yaml | tr -d '\"')"
        #"Control_L&Alt_L, o, exec, $browser -new-tab $(yq .onedrive ~/current_course/info.yaml | tr -d '\"')"
        "Control_L&Alt_L, x, exec, $browser -new-tab $(yq .extra ~/current_course/info.yaml | tr -d '\"')"
        "Control_L&Alt_L, g, exec, $browser -new-tab $(yq .goodnotes ~/current_course/info.yaml | tr -d '\"')"
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
    };
  };
}
