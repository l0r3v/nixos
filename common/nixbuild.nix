{pkgs, ...}: {
  environment.etc."nix/nixbuild.machines".text = ''
    ssh://eu.nixbuild.net x86_64-linux - 100 1 benchmark,big-parallel - -
  '';
  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "nix-cloud" ''
      export NIX_CONFIG="builders = @/etc/nix/nixbuild.machines
            max-jobs = 0
            ''${NIX_CONFIG:-}"
            exec nix "$@"
    '')
    (writeShellScriptBin "nixos-cloud" ''
      exec sudo nixos-rebuild "$@" --option builders @/etc/nix/nixbuild.machines --option max-jobs 0
    '')
    (writeShellScriptBin "deploy-cloud" ''
      export NIX_CONFIG="builders = @/etc/nix/nixbuild.machines
      max-jobs = 0
      ''${NIX_CONFIG:-}"

      exec deploy "$@"
    '')
  ];
}
