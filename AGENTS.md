# NixOS Configuration - Agent Guide

## Commands

- **Deploy (current host):** `deploy .` (deploy-rs, builds locally then pushes via tailscale ssh)
- **Deploy specific host:** `deploy .#<hostname>`
- **Format:** `nix fmt .` (alejandra)
- **Validate:** `nix flake check` (runs deploy-rs checks)
- **Build without deploying:** `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`
- **Distributed build script:** `./distributed_builds.sh build [target]` — builds all or one host, saves logs to `builds/`
- **Edit secrets:** `cd <host-dir> && sops secrets/secrets.yaml`

## Architecture

Single flake at root (`flake.nix`) defines all three hosts. One `flake.lock` for everything.

### Hosts

| Host | User | Home Manager | Sops | Notes |
|------|------|-------------|------|-------|
| `AMDnixos` | `lorev` | Yes | No | Desktop, AMD GPU, stateVersion 25.11 |
| `XPSnixos` | `lorev` | Yes | Yes | Laptop, NVIDIA, stateVersion 24.05 |
| `homelab` | `hspasqui` | **No** | Yes | Headless server, NVIDIA legacy_470, stateVersion 24.11 |

**Never change `system.stateVersion`** on any host.

### Custom Module System

`common/modules/` defines a custom `modules.*` option namespace (not standard NixOS options). Hosts enable features like:

```nix
modules.desktop.niri.enable = true;
modules.programs.firefox.enable = true;
modules.theme.stylix.scheme = "...";
```

Module tree: `common/modules/default.nix` imports `desktop/`, `programs/`, `theme/`, `nix-helpers.nix`, `startup.nix`. It also sets Italian keyboard layout for all importing hosts.

AMDnixos and XPSnixos import `../common/modules` and toggle features via `modules.*`. Homelab does **not** import `common/modules` — it only imports `nix-helpers.nix` from it.

### Sops

`common/sops.nix` dispatches secrets path based on `config.networking.hostName`. Only XPSnixos and homelab import it. Secrets live in `<host>/secrets/secrets.yaml` (age encryption).

### Home Manager

Integrated as NixOS module in flake.nix for AMDnixos and XPSnixos. User config is in `<host>/home.nix`. Homelab has no home-manager.

## Conventions

- `hardware-configuration.nix` is generated — do not hand-edit
- Remote builds use `nixos-builder` ssh user over tailscale
- `builds/` directory is gitignored (build artifacts and logs)
