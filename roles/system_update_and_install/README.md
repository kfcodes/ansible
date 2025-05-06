# Ansible Role: system_setup

This Ansible role prepares a Linux system by:

- Updating installed packages
- Installing default and group-specific packages
- Optionally installing Docker and Docker Compose (Ubuntu only)
- Optionally rebooting the system after upgrade

It is platform-aware and supports Debian, Ubuntu, RedHat, and Fedora systems.

---

## Features

- OS-aware system upgrades using `apt` or `dnf`
- Merges `default_packages` and `group_packages` for clean installs
- Optional Docker & Compose install (Ubuntu only)
- Optional system reboot after updates
- Per-group and per-host variable control

---

## Role Variables

### 🔹 General

| Variable         | Description                                  | Default |
|------------------|----------------------------------------------|---------|
| `default_packages` | List of common packages for all systems    | `[]`    |
| `group_packages`   | Extra packages for group/host-specific use | `[]`    |

### 🔹 Docker (Ubuntu-only)

| Variable              | Description                                 | Default |
|------------------------|---------------------------------------------|---------|
| `install_docker`       | Whether to install Docker and Compose       | `true`  |

### 🔹 Reboot Control

| Variable        | Description                         | Default |
|------------------|-------------------------------------|---------|
| `allow_reboot`   | Reboot system after upgrade         | `true`  |

---
