{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.modules.programs.ssh;
in {
  options.modules.programs.ssh.enable = lib.mkEnableOption "shared ssh client configuration";

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      extraConfig = ''
        Host eu.nixbuild.net
        PubkeyAcceptedKeyTypes ssh-ed25519
        ServerAliveInterval 60
        IPQoS throughput
        IdentityFile /home/lorev/.ssh/my-nixbuild-key
      '';

      knownHosts = {
        nixbuild = {
          hostNames = ["eu.nixbuild.net"];
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
        };
      };
    };
    environment.systemPackages = with pkgs; [
      cloudflared # Lo mettiamo qui così è sempre presente
    ];

    home-manager.users.lorev = _: {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;

        settings = {
          "*" = {
            forwardAgent = true;
            addKeysToAgent = "confirm";
            compression = false;
            serverAliveInterval = 0;
            serverAliveCountMax = 3;
            hashKnownHosts = false;
            userKnownHostsFile = "~/.ssh/known_hosts";
            controlMaster = "no";
            controlPath = "~/.ssh/master-%r@%n:%p";
            controlPersist = "no";
          };

          "xpsnixos.lan" = {
            hostname = "xpsnixos.lan";
            user = "nixos-builder";
            port = 22;
            identityFile = "~/.ssh/nixos-builder";
          };
          "homelab.lan" = {
            hostname = "homelab.lan";
            user = "nixos-builder";
            port = 22;
            identityFile = "~/.ssh/nixos-builder";
          };

          "forge.pasqui.casa" = {
            hostname = "forge.pasqui.casa";
            user = "forgejo";
            port = 2211;
            identityFile = "~/.ssh/id_ed25519";
            proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
          };
          "forge-ssh.pasqui.casa" = {
            hostname = "forge-ssh.pasqui.casa";
            user = "forgejo";
            port = 2211;
            identityFile = "~/.ssh/id_ed25519";
            proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
          };
        };
      };
    };
  };
}
