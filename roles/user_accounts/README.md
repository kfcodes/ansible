# Ansible Role: manage_users

This Ansible role sets up system users, installs SSH public keys, and optionally generates a control node SSH key for the `ansible` user. It is designed for secure, minimal provisioning of remote hosts with Ansible access and sudo rights.

---

## Features

- Creates a default `ansible` user with `sudo` privileges
- Optionally generates an SSH key on the control node and installs it
- Adds inline or file-based public SSH keys to remote users
- Allows external users to be added via `group_vars` or `host_vars`
- Supports optional user removal with `remove: true`
- SSH key management is toggleable per environment

---

## Role Structure

| File                            | Purpose                                      |
|---------------------------------|----------------------------------------------|
| `generate_ssh_key.yml`          | Generates SSH key on control node            |
| `user_accounts.yml`             | Creates or removes system users              |
| `ssh_key_management.yml`        | Adds keys to `authorized_keys` per user      |

---

## Requirements

- Ansible 2.9+
- Linux target hosts (Ubuntu, Debian, RHEL, etc.)
- Public key access or password-based bootstrap access
