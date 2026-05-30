{pkgs, ...}: {
  users.users.nixos-builder = {
    isNormalUser = true;
    description = "NixOS Remote Builder";
    extraGroups = ["wheel"];
    createHome = false;
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEtJmCOrKD6hsDHRPRKjwfJV+Jckr4FFzeE9Wc9wg6gM nixos-rebuild"
    ];
  };

  security.sudo = {
    enable = true;
    extraRules = [
      {
        users = ["nixos-builder"];
        commands = [
          {
            command = "ALL";
            options = ["NOPASSWD" "SETENV"];
          }
        ];
      }
    ];
  };

  nix.settings = {
    trusted-users = ["root" "nixos-builder"];
    experimental-features = ["nix-command" "flakes"];
  };

  environment.systemPackages = with pkgs; [
    git
  ];
}
