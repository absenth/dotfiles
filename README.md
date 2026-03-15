# Dotfiles

This project manages dotfiles and automates development environment setup using two tools:

- **[Chezmoi](https://www.chezmoi.io/)** - A dotfile manager that lets you store your configuration files in a Git repository, keep them under version control, and synchronize them across multiple machines. Chezmoi creates a mapping between a source directory (the repository) and your home directory, handling the complexity of symlinks, templates, and machine-specific configurations.

- **[Ansible](https://www.ansible.com/)** - An open-source automation tool for configuration management, application deployment, and IT orchestration. Ansible uses YAML-based playbooks to define automation tasks, ensuring consistent and repeatable setup across machines. It uses an agentless architecture, communicating via SSH.

## How It Works

This repository serves dual purposes:

1. **Dotfiles** (via Chezmoi): Configuration files in the root of this repository (like `dot_zshrc`, `dot_gitconfig`, `dot_profile`) are managed by Chezmoi. When you run the initialization command, Chezmoi copies or symlinks these files to your home directory, applying any templates for machine-specific customizations.

2. **Automation** (via Ansible): The `ansible/` directory contains playbooks that automatically install packages and configure your development environment on various operating systems.

### Initialization Process

When Chezmoi initializes on a new machine, it automatically executes any script with the `run_once_` prefix. This project includes a `run_once_init.sh` script that:

1. **Detects the operating system** (macOS, FreeBSD, or Linux and its distribution)
2. **Installs Ansible** if not already present (using the system's package manager)
3. **Decrypts SSH keys** from a vault file if present
4. **Runs the appropriate Ansible playbook** based on the detected OS

This automation runs automatically after the initialization command completes, setting up your entire development environment with a single command.

## Requirements

- User must be in the `sudoers` file
- `curl` must be installed

## Initialization

### Linux

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply absenth
```

### FreeBSD

> **Note:** Currently FreeBSD support is broken.

- `sudo` must be installed
- `bash` package must be installed
- `curl` package must be installed

```bash
bash -c "$(curl -fsSL get.chezmoi.io)" -- init --apply absenth
```

### Mac

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply absenth
```

## Testing

Testing has only been performed on:
- ArchLinux
- Fedora 42
- FreeBSD 14 - problems with bob, but otherwise mostly working
- Ubuntu 24.04
