{...}: {
  home.file = {
    ".config/waybar/watch_course.sh".text = ''
      #!/bin/bash
      cat /tmp/current_course'';
    ".config/waybar/get_powermode.sh".source = ./waybar/get_powermode.sh;
    ".config/waybar/set_powermode.sh".source = ./waybar/set_powermode.sh;
    ".config/wallpaper/nix-transp.png".source = ./wallpaper/nix-transp.png;
    ".p10k.zsh".source = ./p10k.zsh;
  };
}
