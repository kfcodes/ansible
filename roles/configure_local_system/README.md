# Ansible Role: setup_local_dev

This Ansible role automates the setup of a personal development environment on a Linux system. It handles symbolic linking of dotfiles, environment variable setup, development repository cloning, app dependency installation, and more — all under a specified local user account.

---

## Features

- Creates symbolic links for dotfiles and configuration files
- Creates `.env` links for local dev apps (React, FastAPI)
- Clones Git repositories for personal projects, dotfiles, scripts, and dev tools
- Installs Python and NPM package dependencies
- Creates and manages app-specific data directories
- Generates a `.gitconfig` file from a Jinja2 template

---

## Variables

All variables can be overridden in `group_vars` or passed via `--extra-vars`.

### 🔹 `local_usr` (default: current ansible_user_id)
The user under whose home directory everything will be configured.

### 🔹 `dotfile_links`

A list of symbolic link mappings for dotfiles:

```yaml
dotfile_links:
  - { src: ".dotfiles/.Xresources", dest: ".Xresources" }
  - { src: ".nvim", dest: ".config/nvim" }
