# NixOS Configurations

This repository contains the **NixOS configurations** for multiple hosts, organized as a collection of independent Nix Flakes sharing common modules. It is designed to manage personal workstations, laptops, and a homelab server using Infrastructure as Code principles.

## Architecture

The project follows a **multi-host, modular architecture**:

- **Host Directories:** Each machine has its own directory containing a `flake.nix`, `configuration.nix`, and host-specific settings.
  - `AMDnixos/`: Configuration for the main desktop workstation.
  - `XPSnixos/`: Configuration for a Dell XPS 15 9500 laptop.
  - `homelab/`: Configuration for a home server/lab environment.
- **Common Modules:**
  - `common/`: Contains shared Nix modules used across hosts to avoid duplication.
  - `common/modules/`: structured sub-modules for `desktop` environments (Hyprland, Niri, Gnome), `programs` (CLI tools, GUI apps), and `theme` (Stylix integration).

## Key Technologies

- **NixOS & Flakes:** The core configuration management system.
- **Home Manager:** Manages user-specific configurations (dotfiles) integrated as a NixOS module.
- **Sops-nix:** Handles secret management (encrypted secrets in `secrets/` directories).
- **Stylix:** Unified system theming.
- **Wayland Compositors:** Supports Hyprland and Niri.
- **Nixvim:** Declarative Neovim configuration (pulled as an input from [my repo](https://github.com/l0r3v/nixvim)).

## Building and Running

Since each host has its own flake, commands are typically run from the respective host directory or by referencing the specific flake URI.

### Applying Configuration

To rebuild the system for a specific host (e.g., `XPSnixos`):

```bash
# Navigate to the host directory
cd XPSnixos

# Apply configuration
sudo nixos-rebuild switch --flake .#XPSnixos
```

### Formatting

The project uses `alejandra` for formatting Nix files.

```bash
nix fmt
```

### Secret Management

Secrets are managed with `sops`. To edit secrets for a specific host:

```bash
cd XPSnixos
sops secrets/secrets.yaml
```

## Directory Structure

- `AMDnixos/`: Host config for AMD Desktop.
- `XPSnixos/`: Host config for Dell XPS Laptop.
- `homelab/`: Host config for Home Server (Docker, Services).
- `common/`:
  - `modules/`: Reusable NixOS modules.
  - `distributed-builds.nix`: Config for remote building.
- `.github/`: CI/CD workflows (formatting checks, flake updates).
