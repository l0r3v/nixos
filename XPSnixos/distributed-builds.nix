{pkgs, ...}: {
  nix = {
    distributedBuilds = true;
    settings.builders-use-substitutes = true;

    buildMachines = [
      {
        hostName = "homelab.tail0e73ab.ts.net";
        sshUser = "remotebuild";
        sshKey = "/root/.ssh/remotebuild";
        inherit (pkgs.stdenv.hostPlatform) system;
        supportedFeatures = ["nixos-test" "big-parallel" "kvm"];
      }
    ];
  };
}
