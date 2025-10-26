{
  pkgs,
  inputs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  niriPackage = inputs.niri-flake.packages.${system}.niri or inputs.niri-flake.packages.${system}.default;
  startupCommands = [
    "nm-applet --indicator"
    "waybar"
    "dunst"
    "blueman-applet"
    "gammastep-indicator -l 45.068371:7.683070"
    "hacompanion"
    "owncloud"
    "bash /home/lorev/lid-monitor.sh"
  ];
  monitorConfig = [
    {
      name = "eDP-1";
      mode = "preferred";
      position = "auto";
      scale = 1.0;
    }
    {
      name = "DP-2";
      mode = "preferred";
      position = "auto-right";
      scale = 1.0;
    }
  ];
  keybinds = [
    { combo = "Super+Escape"; action = "spawn"; command = "bash ~/.config/scripts/powermenu.sh"; }
    { combo = "Super+Return"; action = "spawn"; command = "ghostty"; }
    { combo = "Super+Q"; action = "close"; }
    { combo = "Super+M"; action = "quit"; }
    { combo = "Super+E"; action = "spawn"; command = "firefox"; }
    { combo = "Super+Space"; action = "toggle-floating"; }
    { combo = "Super+R"; action = "spawn"; command = "rofi -show drun"; }
    { combo = "Super+P"; action = "toggle-pseudo"; }
    { combo = "Super+V"; action = "toggle-split"; }
    { combo = "Super+H"; action = "focus-left"; }
    { combo = "Super+L"; action = "focus-right"; }
    { combo = "Super+K"; action = "focus-up"; }
    { combo = "Super+J"; action = "focus-down"; }
    { combo = "Super+1"; action = "workspace"; workspace = "1"; }
    { combo = "Super+2"; action = "workspace"; workspace = "2"; }
    { combo = "Super+3"; action = "workspace"; workspace = "3"; }
    { combo = "Super+4"; action = "workspace"; workspace = "4"; }
    { combo = "Super+5"; action = "workspace"; workspace = "5"; }
    { combo = "Super+6"; action = "workspace"; workspace = "6"; }
    { combo = "Super+7"; action = "workspace"; workspace = "7"; }
    { combo = "Super+8"; action = "workspace"; workspace = "8"; }
    { combo = "Super+9"; action = "workspace"; workspace = "9"; }
    { combo = "Super+0"; action = "workspace"; workspace = "10"; }
    { combo = "Super+Shift+1"; action = "move-to-workspace"; workspace = "1"; }
    { combo = "Super+Shift+2"; action = "move-to-workspace"; workspace = "2"; }
    { combo = "Super+Shift+3"; action = "move-to-workspace"; workspace = "3"; }
    { combo = "Super+Shift+4"; action = "move-to-workspace"; workspace = "4"; }
    { combo = "Super+Shift+5"; action = "move-to-workspace"; workspace = "5"; }
    { combo = "Super+Shift+6"; action = "move-to-workspace"; workspace = "6"; }
    { combo = "Super+Shift+7"; action = "move-to-workspace"; workspace = "7"; }
    { combo = "Super+Shift+8"; action = "move-to-workspace"; workspace = "8"; }
    { combo = "Super+Shift+9"; action = "move-to-workspace"; workspace = "9"; }
    { combo = "Super+Shift+0"; action = "move-to-workspace"; workspace = "10"; }
    { combo = "Super+S"; action = "toggle-special-workspace"; workspace = "magic"; }
    { combo = "Super+Shift+S"; action = "move-to-special-workspace"; workspace = "magic"; }
    { combo = "Super+Shift+K"; action = "workspace-relative"; workspace = "+1"; }
    { combo = "Super+Shift+J"; action = "workspace-relative"; workspace = "-1"; }
    { combo = "Super+mouse_down"; action = "workspace-relative"; workspace = "+1"; }
    { combo = "Super+mouse_up"; action = "workspace-relative"; workspace = "-1"; }
    { combo = "Super+N"; action = "workspace-relative"; workspace = "+1"; }
    { combo = "Super+Shift+N"; action = "move-to-workspace-relative"; workspace = "+1"; }
    { combo = "Super+B"; action = "workspace-relative"; workspace = "-1"; }
    { combo = "Super+Shift+B"; action = "move-to-workspace-relative"; workspace = "-1"; }
    { combo = "Super+F"; action = "toggle-fullscreen"; }
    { combo = "Super+C"; action = "spawn"; command = "zathura ~/calendar"; }
    { combo = "Control_L+Alt_R+T"; action = "spawn"; command = "ghostty -d ~/current_course"; }
    { combo = "Control_L+Alt_R+N"; action = "spawn"; command = "ghostty -d ~/current_course --hold sh -c nvim"; }
    { combo = "Control_L+Alt_R+L"; action = "spawn"; command = "rofi-lectures"; }
    { combo = "Control_L+Alt_R+C"; action = "spawn"; command = "rofi-courses"; }
    { combo = "Control_L+Alt_R+V"; action = "spawn"; command = "rofi-lectures-view"; }
    { combo = "Control_L+Alt_R+B"; action = "spawn"; command = "backup-uni"; }
    { combo = "Control_L+Alt_R+S"; action = "spawn"; command = "bash ~/university-setup/other/select_subfolder"; }
    { combo = "Control_L+Alt_R+P"; action = "spawn"; command = "select_file-uni"; }
    { combo = "Control_L+Alt_R+Y"; action = "spawn"; command = "select_file-uni rec"; }
    { combo = "Control_L+Alt_R+I"; action = "spawn"; command = "bash ~/university-setup/other/scrsht_util.sh"; }
    { combo = "Control_L+Alt_R+W"; action = "spawn"; command = "firefox -new-tab $(yq .link ~/current_course/info.yaml | tr -d '\\"')"; }
    { combo = "Control_L+Alt_R+X"; action = "spawn"; command = "firefox -new-tab $(yq .extra ~/current_course/info.yaml | tr -d '\\"')"; }
    { combo = "Control_L+Alt_R+G"; action = "spawn"; command = "firefox -new-tab $(yq .goodnotes ~/current_course/info.yaml | tr -d '\\"')"; }
    { combo = "Control_L+Shift+L"; action = "spawn"; command = "rofi-rbw --no-help --keybindings Ctrl+1:type:username,Ctrl+2:type:password,Ctrl+3:type:totp"; }
    { combo = "Control_L+Shift+A"; action = "spawn"; command = "rofi-pulse-select sink"; }
  ];
  axisBinds = [
    { combo = "XF86AudioRaiseVolume"; action = "spawn"; command = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"; }
    { combo = "XF86AudioLowerVolume"; action = "spawn"; command = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"; }
    { combo = "XF86AudioMute"; action = "spawn"; command = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
    { combo = "XF86AudioMicMute"; action = "spawn"; command = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }
    { combo = "XF86MonBrightnessUp"; action = "spawn"; command = "brightnessctl s 5%+"; }
    { combo = "XF86MonBrightnessDown"; action = "spawn"; command = "brightnessctl s 5%-"; }
  ];
  pointerBinds = [
    { combo = "Super+mouse:272"; action = "move-window"; }
    { combo = "Super+mouse:273"; action = "resize-window"; }
  ];
  lidBinds = [
    { combo = "switch:Lid Switch"; action = "spawn"; command = "bash ~/lid-monitor.sh"; }
  ];
  envVars = {
    GTK_SCALE = "2";
    XCURSOR_SIZE = "32";
  };
  renderConfig = {
    borderWidth = 2;
    gapsInner = 2;
    gapsOuter = 4;
    cornerRadius = 10;
    opacityActive = 1.0;
    opacityInactive = 1.0;
  };
in {
  home.packages = [niriPackage];
  xdg.configFile."niri/config.kdl".text = let
    formatMonitor = monitor:
      with monitor; ''  output "${name}" {
    mode "${mode}"
    position "${position}"
    scale ${builtins.toString scale}
  }
'';
    formatKeybind = bind:
      with bind;
        ''  bind "${combo}" ${action}$
'';
  in ''// Autogenerated from former Hyprland configuration.
layout {
  gaps { inner ${renderConfig.gapsInner}; outer ${renderConfig.gapsOuter}; }
  border { width ${renderConfig.borderWidth}; }
  corner-radius ${renderConfig.cornerRadius};
  opacity { active ${renderConfig.opacityActive}; inactive ${renderConfig.opacityInactive}; }
}

environment {
  GTK_SCALE "${envVars.GTK_SCALE}"
  XCURSOR_SIZE "${envVars.XCURSOR_SIZE}"
}

spawn-at-startup {
${pkgs.lib.concatStringsSep "" (map (cmd: "  command \"" + cmd + "\"\n") startupCommands)}
}

${pkgs.lib.concatStringsSep "" (map formatMonitor monitorConfig)}

bindings {
${pkgs.lib.concatStringsSep "" (map (bind: let
      baseAction = bind.action;
      payload = if baseAction == "spawn" then '' { spawn "${bind.command}" }''
        else if baseAction == "workspace" then '' { workspace "${bind.workspace}" }''
        else if baseAction == "move-to-workspace" then '' { move-window-to-workspace "${bind.workspace}" }''
        else if baseAction == "toggle-special-workspace" then '' { toggle-special-workspace "${bind.workspace}" }''
        else if baseAction == "move-to-special-workspace" then '' { move-window-to-special-workspace "${bind.workspace}" }''
        else if baseAction == "workspace-relative" then '' { workspace-relative "${bind.workspace}" }''
        else if baseAction == "move-to-workspace-relative" then '' { move-window-to-workspace-relative "${bind.workspace}" }''
        else if baseAction == "toggle-fullscreen" then '' { toggle-fullscreen }''
        else if baseAction == "toggle-floating" then '' { toggle-floating }''
        else if baseAction == "toggle-pseudo" then '' { toggle-pseudo }''
        else if baseAction == "toggle-split" then '' { toggle-split }''
        else if baseAction == "focus-left" then '' { focus-left }''
        else if baseAction == "focus-right" then '' { focus-right }''
        else if baseAction == "focus-up" then '' { focus-up }''
        else if baseAction == "focus-down" then '' { focus-down }''
        else if baseAction == "close" then '' { close }''
        else if baseAction == "quit" then '' { quit }''
        else '' { ${baseAction} }'';
    in ''  bind "${bind.combo}"${payload}
'') keybinds)}
${pkgs.lib.concatStringsSep "" (map (bind: ''  bind "${bind.combo}" { spawn "${bind.command}" }
'') axisBinds)}
${pkgs.lib.concatStringsSep "" (map (bind: ''  bind "${bind.combo}" { ${bind.action} }
'') pointerBinds)}
${pkgs.lib.concatStringsSep "" (map (bind: ''  bind "${bind.combo}" { spawn "${bind.command}" }
'') lidBinds)}
}
'';
}
