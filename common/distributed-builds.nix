{pkgs, ...}: {
  nix = {
    distributedBuilds = false;
    settings.builders-use-substitutes = true;

    buildMachines = [
      {
        hostName = "eu.nixbuild.net";
        system = "x86_64-linux";
        maxJobs = 100;
        supportedFeatures = ["benchmark" "big-parallel"];
      }
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
