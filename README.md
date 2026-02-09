# NixOS Configurations

This repository contains the **NixOS configurations** for multiple hosts. It is designed to manage my devices.

## Architecture

The configuration is composed by a sigle flake and some modules (mainly for amd and xps since they have similar usecases).

- **Host Directories:** Each machine has its own directory containing a configuration.nix where the modules are called. I am in the process of modulazing the configuration some more, to potentially only have modules setting in the configuration files.
  - `AMDnixos/`: Configuration for the main desktop workstation.
  - `XPSnixos/`: Configuration for Dell XPS 15 9500 laptop.
  - `homelab/`: Configuration for home server/lab environment.
- **Common Modules:**
  - `common/`: Contains shared Nix modules used across hosts to avoid duplication.
  - `common/modules/`: structured sub-modules for `desktop` environments (Hyprland, Niri, Gnome), `programs` (CLI tools, GUI apps), and `theme` (Stylix integration). This is what i want to expand more.

## Some features

-**Flake based configuration**

- **Home Manager:** Manages user-specific configurations (dotfiles) integrated as a NixOS module.
- **Sops-nix:** Handles secret management (encrypted secrets in `secrets/` directories).
- **Stylix:** Unified system theming.
- **Wayland Compositors:** Supports Hyprland and Niri.
- **Nixvim:** Declarative Neovim configuration (pulled as an input from [my repo](https://github.com/l0r3v/nixvim)).

## Building and Running

This is as simple as writing in a terminal

```bash
deploy .
```

All is built on the local machine and then copied to the others through tailscale ssh.

### Formatting

The project uses `alejandra` for formatting Nix files.

```bash
alejandra .
```

or

```bash
nix fmt .
```

### Secret Management

Secrets are managed with `sops`. To edit secrets for a specific host:

```bash
cd $HOST
sops secrets/secrets.yaml
```

## Directory Structure

- `AMDnixos/`: Host config for AMD Desktop.
- `XPSnixos/`: Host config for Dell XPS Laptop.
- `homelab/`: Host config for Home Server (Docker, Services).
- `common/`:
  - `modules/`: Reusable NixOS modules.
  - `distributed-builds.nix`: Config for remote building.
- `.github/`: CI/CD workflows (formatting checks, flake updates). This is currently a mess since there are both github specific and gitea ones.
