{pkgs, ...}: {
  nix = {
    distributedBuilds = true;
    settings.builders-use-substitutes = true;

    buildMachines = [
      {
        hostName = "amdnixos.lan";
        sshUser = "remotebuild";
        sshKey = "/root/.ssh/remotebuild";
        inherit (pkgs.stdenv.hostPlatform) system;
        supportedFeatures = ["nixos-test" "big-parallel" "kvm"];
      }
    ];
  };
}
