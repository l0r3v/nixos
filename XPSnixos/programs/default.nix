{...}: {
  imports = [
    ./nnn.nix
    ./zsh.nix
    ./zathura.nix
    ./rofi.nix
    ./waybar
    ./firefox.nix
    ./kitty.nix
    ./hyprland.nix
    ./alacritty.nix
    #./qutebrowser unfortunately qt5 is not secure. Need to wait for qutebrowser to be ported in qt6
    ./mpv.nix
    ./thunderbird.nix
    ./rbw.nix
    #./eww.nix
    ./ghostty.nix
  ];
}
