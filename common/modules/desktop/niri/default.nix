{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.modules.desktop.niri;
  hostname = config.networking.hostName;
in {
  options.modules.desktop.niri = {
    enable = lib.mkEnableOption "Niri Window Manager";
  };
  imports = [inputs.niri.nixosModules.niri];
  config = lib.mkIf cfg.enable {
    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gnome # Ottimo per dark mode e settings su Niri
        pkgs.xdg-desktop-portal-gtk # Fallback solido
      ];
      config = {
        # Per Niri, usa gnome come primario, gtk come fallback
        niri = {
          default = ["gnome" "gtk"];
          # Per gli screenshot/screencast niri gestisce da solo, o delega a gnome
          "org.freedesktop.impl.portal.ScreenCast" = ["gnome"];
          "org.freedesktop.impl.portal.Screenshot" = ["gnome"];
        };
        # Fallback generico
        common = {
          default = ["gtk"];
        };
      };
    };
    nixpkgs.overlays = [inputs.niri.overlays.niri];
    programs.xwayland.enable = true;
    programs.niri.enable = true;
    environment.systemPackages = with pkgs; [
      xwayland-satellite
      swaybg
      libnotify # per dunst
      dunst
      networkmanagerapplet # nm-applet
      fuzzel
    ];
    services.displayManager.sessionPackages = [
      pkgs.niri
    ];

    home-manager.users.lorev = _: {
      programs.fuzzel.enable = true;
      stylix.targets.fuzzel.fonts.enable = false;

      home.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        MOZ_ENABLE_WAYLAND = "1";
        XDG_SESSION_TYPE = "wayland";
        XDG_CURRENT_DESKTOP = "Niri";
        XDG_SESSION_DESKTOP = "Niri";
      };
      programs.niri = {
        package = pkgs.niri-unstable;
        settings = {
          # --- Input ---
          input = {
            keyboard = {
              xkb = {
                # Se vuoi personalizzare layout qui: layout = "it";
              };
            };

            touchpad = {
              tap = true;
              natural-scroll = true;
              # dwt = true;
            };

            # focus-follows-mouse.max-scroll-amount = "0%";
          };

          # --- Outputs ---
          outputs =
            if (hostname == "XPSnixos")
            then {
              # Configurazione SOLO per il Laptop
              "eDP-1" = {
                mode = {
                  width = 1920;
                  height = 1200;
                };
                scale = 1.0;
              };
            }
            else {
              # Configurazione SOLO per il Fisso (AMDnixos)
              "DP-3" = {
                mode = {
                  width = 1920;
                  height = 1080;
                };
                scale = 1.0;
              };
            };

          # --- Layout ---
          layout = {
            gaps = 6;
            center-focused-column = "never";

            preset-column-widths = [
              {proportion = 0.33333;}
              {proportion = 0.5;}
              {proportion = 0.66667;}
            ];

            default-column-width = {proportion = 0.5;};

            # Focus Ring
            focus-ring = {
              width = 0.5;
            };

            # Ombre
            shadow = {
              softness = 30;
              spread = 5;
              offset = {
                x = 0;
                y = 5;
              };
              color = "#0007";
            };
          };

          # --- Startup ---
          spawn-at-startup = [
            {argv = ["waybar"];}
            {argv = ["nm-applet"];}
            {argv = ["dunst"];}
            {argv = ["blueman-applet"];}
            {argv = ["hacompanion"];}
            {argv = ["owncloud"];}
            # Usa sh -c per comandi complessi
            {argv = ["gammastep-indicator" "-l" "45.068371:7.683070"];}

            # FIX: Wallpaper dinamico con Stylix
            {
              argv = ["swaybg" "-m" "fill" "-i" "${config.stylix.image}"];
            }
          ];

          # --- Misc Settings ---
          prefer-no-csd = true;
          screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

          hotkey-overlay.skip-at-startup = true;

          # --- Animations ---
          animations = {
            # slowdown = 3.0;
          };

          # --- Window Rules ---
          window-rules = let
            colors = config.lib.stylix.colors.withHashtag;
          in [
            {
              geometry-corner-radius = let
                r = 12.0;
              in {
                top-left = r;
                top-right = r;
                bottom-left = r;
                bottom-right = r;
              };
              clip-to-geometry = true;
            }
            {
              matches = [
                {
                  app-id = "firefox$";
                  title = "^Picture-in-Picture$";
                  is-floating = true;
                }
              ];
              open-floating = true;
              default-floating-position = {
                relative-to = "bottom";
                x = 0;
                y = -60;
              };
            }
          ];

          # --- Key Bindings ---
          binds = {
            # Apps Essential
            "Mod+Return".action.spawn = "ghostty";
            "Mod+E".action.spawn = "firefox";
            "Mod+Space".action.spawn = "fuzzel";
            "Mod+Escape".action.spawn = "/home/lorev/.config/scripts/powermenu.sh";

            # --- UNIVERSITY SHORTCUTS ---
            "Control+Alt+T".action.spawn = ["ghostty" "-d" "/home/lorev/current_course"];
            "Control+Alt+N".action.spawn = ["ghostty" "-d" "/home/lorev/current_course" "--hold" "sh" "-c" "nvim"];

            "Control+Alt+L".action.spawn = "rofi-lectures";
            "Control+Alt+C".action.spawn = "rofi-courses";
            "Control+Alt+V".action.spawn = "rofi-lectures-view";
            "Control+Alt+B".action.spawn = "backup-uni";
            "Control+Alt+S".action.spawn = "/home/lorev/university-setup/other/select_subfolder";
            "Control+Alt+P".action.spawn = "select_file-uni";
            "Control+Alt+Y".action.spawn = ["select_file-uni" "rec"];
            "Control+Alt+I".action.spawn = "/home/lorev/university-setup/other/scrsht_util.sh";

            # Audio / Media (allow-when-locked)
            "XF86AudioRaiseVolume" = {
              allow-when-locked = true;
              action.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+" "-l" "1.0"];
            };
            "XF86AudioLowerVolume" = {
              allow-when-locked = true;
              action.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"];
            };
            "XF86AudioMute" = {
              allow-when-locked = true;
              action.spawn = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];
            };
            "XF86AudioMicMute" = {
              allow-when-locked = true;
              action.spawn = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"];
            };

            "XF86AudioPlay" = {
              allow-when-locked = true;
              action.spawn = ["playerctl" "play-pause"];
            };
            "XF86AudioStop" = {
              allow-when-locked = true;
              action.spawn = ["playerctl" "stop"];
            };
            "XF86AudioPrev" = {
              allow-when-locked = true;
              action.spawn = ["playerctl" "previous"];
            };
            "XF86AudioNext" = {
              allow-when-locked = true;
              action.spawn = ["playerctl" "next"];
            };

            # Brightness
            "XF86MonBrightnessUp" = {
              allow-when-locked = true;
              action.spawn = ["brightnessctl" "set" "10%+"];
            };
            "XF86MonBrightnessDown" = {
              allow-when-locked = true;
              action.spawn = ["brightnessctl" "set" "10%-"];
            };

            # Window Management
            "Mod+Q".action.close-window = [];
            "Mod+O".action.toggle-overview = [];

            # Focus Navigation
            "Mod+H".action.focus-column-left = [];
            "Mod+J".action.focus-window-or-workspace-down = [];
            "Mod+K".action.focus-window-or-workspace-up = [];
            "Mod+L".action.focus-column-right = [];

            "Mod+Home".action.focus-column-first = [];
            "Mod+End".action.focus-column-last = [];

            # Move Windows
            "Mod+Shift+H".action.move-column-left = [];
            "Mod+Shift+J".action.move-window-down-or-to-workspace-down = [];
            "Mod+Shift+K".action.move-window-up-or-to-workspace-up = [];
            "Mod+Shift+L".action.move-column-right = [];

            "Mod+Ctrl+Home".action.move-column-to-first = [];
            "Mod+Ctrl+End".action.move-column-to-last = [];

            # Monitor Navigation
            "Mod+Ctrl+Left".action.focus-monitor-left = [];
            "Mod+Ctrl+Down".action.focus-monitor-down = [];
            "Mod+Ctrl+Up".action.focus-monitor-up = [];
            "Mod+Ctrl+Right".action.focus-monitor-right = [];
            "Mod+Ctrl+H".action.focus-monitor-left = [];
            "Mod+Ctrl+J".action.focus-monitor-down = [];
            "Mod+Ctrl+K".action.focus-monitor-up = [];
            "Mod+Ctrl+L".action.focus-monitor-right = [];

            # Move Column to Monitor
            "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [];
            "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = [];
            "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = [];
            "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [];
            "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [];
            "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = [];
            "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = [];
            "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [];

            # Workspace Navigation
            "Mod+Page_Down".action.focus-workspace-down = [];
            "Mod+Page_Up".action.focus-workspace-up = [];
            "Mod+U".action.focus-workspace-down = [];
            "Mod+I".action.focus-workspace-up = [];

            "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = [];
            "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = [];
            "Mod+Ctrl+U".action.move-column-to-workspace-down = [];
            "Mod+Ctrl+I".action.move-column-to-workspace-up = [];

            "Mod+Shift+Page_Down".action.move-workspace-down = [];
            "Mod+Shift+Page_Up".action.move-workspace-up = [];
            "Mod+Shift+U".action.move-workspace-down = [];
            "Mod+Shift+I".action.move-workspace-up = [];

            # Mouse Wheel Binds
            "Mod+WheelScrollDown".action.focus-workspace-down = [];
            "Mod+WheelScrollUp".action.focus-workspace-up = [];
            "Mod+Ctrl+WheelScrollDown".action.move-column-to-workspace-down = [];
            "Mod+Ctrl+WheelScrollUp".action.move-column-to-workspace-up = [];

            "Mod+WheelScrollRight".action.focus-column-right = [];
            "Mod+WheelScrollLeft".action.focus-column-left = [];
            "Mod+Ctrl+WheelScrollRight".action.move-column-right = [];
            "Mod+Ctrl+WheelScrollLeft".action.move-column-left = [];

            # Workspaces 1-9
            "Mod+1".action.focus-workspace = 1;
            "Mod+2".action.focus-workspace = 2;
            "Mod+3".action.focus-workspace = 3;
            "Mod+4".action.focus-workspace = 4;
            "Mod+5".action.focus-workspace = 5;
            "Mod+6".action.focus-workspace = 6;
            "Mod+7".action.focus-workspace = 7;
            "Mod+8".action.focus-workspace = 8;
            "Mod+9".action.focus-workspace = 9;

            "Mod+Ctrl+1".action.move-column-to-workspace = 1;
            "Mod+Ctrl+2".action.move-column-to-workspace = 2;
            "Mod+Ctrl+3".action.move-column-to-workspace = 3;
            "Mod+Ctrl+4".action.move-column-to-workspace = 4;
            "Mod+Ctrl+5".action.move-column-to-workspace = 5;
            "Mod+Ctrl+6".action.move-column-to-workspace = 6;
            "Mod+Ctrl+7".action.move-column-to-workspace = 7;
            "Mod+Ctrl+8".action.move-column-to-workspace = 8;
            "Mod+Ctrl+9".action.move-column-to-workspace = 9;

            # Consume/Expel
            "Mod+BracketLeft".action.consume-or-expel-window-left = [];
            "Mod+BracketRight".action.consume-or-expel-window-right = [];
            "Mod+Comma".action.consume-window-into-column = [];
            "Mod+Period".action.expel-window-from-column = [];

            # Sizing
            "Mod+R".action.switch-preset-column-width = [];
            "Mod+Shift+R".action.switch-preset-window-height = [];
            "Mod+Ctrl+R".action.reset-window-height = [];
            "Mod+F".action.maximize-column = [];
            "Mod+Shift+F".action.fullscreen-window = [];
            "Mod+Ctrl+F".action.expand-column-to-available-width = [];
            "Mod+C".action.center-column = [];
            "Mod+Ctrl+C".action.center-visible-columns = [];

            "Mod+Minus".action.set-column-width = "-10%";
            "Mod+Equal".action.set-column-width = "+10%";
            "Mod+Shift+Minus".action.set-window-height = "-10%";
            "Mod+Shift+Equal".action.set-window-height = "+10%";

            # Misc
            "Mod+V".action.toggle-window-floating = [];
            "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [];
            "Mod+W".action.toggle-column-tabbed-display = [];

            # Screenshots
            "Print".action.screenshot = [];
            "Ctrl+Print".action.screenshot-screen = [];
            "Alt+Print".action.screenshot-window = [];

            "Mod+Shift+E".action.quit = [];
            "Ctrl+Alt+Delete".action.quit = [];
            "Mod+Shift+P".action.power-off-monitors = [];
          };
        };
      };
    };
  };
}
