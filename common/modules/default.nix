{...}: {
  imports = [
    ./desktop
    ./programs
    ./theme
    ./nix-helpers.nix
    ./startup.nix
  ];
  console.keyMap = "it2";
  services.xserver.xkb = {
    layout = "it";
    variant = "";
  };
}
