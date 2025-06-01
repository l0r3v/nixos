{...}: {
  home.file = {
    ".config/waybar/watch_course.sh".text = ''
      #!/bin/bash
      cat /tmp/current_course'';
    ".config/waybar/get_powermode.sh" = {
      source = ./waybar/get_powermode.sh;
      executable = true;
    };
    ".config/waybar/set_powermode.sh" = {
      source = ./waybar/set_powermode.sh;
      executable = true;
    };
    ".config/wallpaper/nix-transp.png" = {
      source = ./wallpaper/nix-transp.png;
      executable = true;
    };
    ".config/waybar/music.sh" = {
      source = ./waybar/music.sh;
      executable = true;
    };
    ".p10k.zsh".source = ./p10k.zsh;
  };
}
