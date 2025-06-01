{pkgs, ...}: {
  home.packages = with pkgs; [
    nh # nix-helper (wrapper per nixos-rebuild + gc + flake)
    nix-index # indicizza comandi nei pacchetti
    nix-tree # visualizza dipendenze di uno store path
    nix-du # mostra spazio occupato nello store
    statix # linter per codice nix
    deadnix # trova codice morto

    nvd
    nix-output-monitor
    nix-diff
  ];

  programs.nix-index.enable = true; # auto run post-activation
}
