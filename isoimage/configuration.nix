{
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  services.xserver.xkb = {
    layout = "it";
  };
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Configure console keymap
  console.keyMap = "it2";
  environment.systemPackages = with pkgs; [
    git
    neovim
    zoxide
    htop-vim
    nh
  ];
}
