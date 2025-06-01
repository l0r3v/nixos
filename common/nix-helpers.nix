{inputs,pkgs, ...}: {
  imports = [
    ./nixos-cli.nix
  ];

  environment= {
    sessionVariables = {
          NH_FLAKE = "$HOME/nixos/$HOST";
    FLAKE = "$HOME/nixos/$HOST";
    NIXOS_CONFIG = "$HOME/nixos/$HOST";

    };
    systemPackages = with pkgs; [
    inputs.optnix.packages."${pkgs.system}".optnix
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
  };
  programs.nix-index.enable = true; # auto run post-activation
  programs.nix-index.enableZshIntegration = false;
  programs.nix-index.enableBashIntegration = false;
}
