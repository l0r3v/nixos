{...}: {
  imports = [
    ./desktop
    ./programs
    ./theme
    ./nix-helpers.nix
  ];
  console.keyMap = "it2";
  services.xserver.xkb = {
    layout = "it";
    variant = "";
  };
}
