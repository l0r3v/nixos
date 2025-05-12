{pkgs, ...}: {
  imports = [
    ./nnn.nix
    ./zsh.nix
    ./zathura.nix
    ./stylix.nix
    ./rofi.nix
    ./waybar.nix
    ./firefox.nix
    ./texlive.nix
    ./hyprland.nix
    ./alacritty.nix
  ];
}
