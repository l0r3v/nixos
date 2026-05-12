{pkgs, ...}: {
  nix = {
    distributedBuilds = true;
    settings.builders-use-substitutes = true;

    buildMachines = [
      {
        hostName = "amdnixos.lan";
        sshUser = "remotebuild";
        sshKey = "/root/.ssh/remotebuild";
        maxJobs = 8;
        inherit (pkgs.stdenv.hostPlatform) system;
        supportedFeatures = ["nixos-test" "big-parallel" "kvm"];
      }
    ];
  };
  environment.etc."nix/nixbuild.machines".text = ''
    ssh://eu.nixbuild.net x86_64-linux - 100 1 benchmark,big-parallel - -
  '';
  environment.systemPackages = with pkgs; [
    #use nix command with nixbuild
    (writeShellScriptBin "nix-cloud" ''
      export NIX_CONFIG="builders = @/etc/nix/nixbuild.machines
            max-jobs = 0
            ''${NIX_CONFIG:-}"
            exec nix "$@"
    '')
    #use nixos-rebuild command with nixbuild
    (writeShellScriptBin "nixos-cloud" ''
      exec sudo nixos-rebuild "$@" --option builders @/etc/nix/nixbuild.machines --option max-jobs 0
    '')
    #use deploy command with nixbuild
    (writeShellScriptBin "deploy-cloud" ''
      #we need to export the NIX_CONFIG variable
      export NIX_CONFIG="builders = @/etc/nix/nixbuild.machines
      max-jobs = 0
      ''${NIX_CONFIG:-}"

      exec deploy "$@"
    '')
  ];
}
