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
  # Fix niri-flake (sodiboo/niri-flake): il suo flake.nix fa
  #   assert libdisplay-info_0_2.version == "0.2.0"
  # e `callPackage` prende libdisplay-info_0_2 dal package set finale.
  # nixpkgs ha rimosso l'attributo (aliases.nix, "Added 2026-08-04"), quindi lo ricostruiamo
  # dalla VERA 0.2.0: stessa ricetta generic.nix di nixpkgs, hash della derivazione storica
  # (verificata identica tra la rev che buildava la 0.2.0 e l'attuale).
  # Da rimuovere SOLO quando niri master migrerà a libdisplay-info >= 0.3 e il niri-flake
  # toglierà l'assert.
  nixpkgs.overlays = [
    (final: prev: {
      libdisplay-info_0_2 = prev.libdisplay-info.overrideAttrs (old: {
        version = "0.2.0";
        src = prev.fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "emersion";
          repo = "libdisplay-info";
          tag = "0.2.0";
          hash = "sha256-6xmWBrPHghjok43eIDGeshpUEQTuwWLXNHg7CnBUt3Q=";
        };
      });
    })
  ];
}
