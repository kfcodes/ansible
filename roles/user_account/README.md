# Role: user_account

Manages Linux user accounts and SSH access.

## Owns

- User creation/removal
- Group membership
- Password locking
- Passwordless sudoers files
- Authorized SSH keys
- Optional per-user SSH config
- Optional control-node SSH key generation

## Does not own

- SSH daemon hardening
- Firewall rules
- Docker setup
- Application deployment
- GitHub-specific dev SSH config

GitHub SSH setup belongs to `system_dev`.

## Expected usage

Used by:

- `configure_security.yml` for the deploy automation user
- `configure_kiosk.yml` for the kiosk user
- `provision_hosts.yml` for dev/control users

## OS-family behavior

Admin group should be provided by:

~~~yaml
linux_admin_group: "{{ 'wheel' if ansible_os_family == 'RedHat' else 'sudo' }}"
~~~

Use this variable instead of hardcoding `sudo`.

## Variables

Important variables:

- `managed_users`
- `user_defaults`
- `linux_admin_group`
- `ssh_keys_to_generate`
- `user_account_sudoers_dir`
- `user_account_validate_sudoers`

## Example managed user

~~~yaml
managed_users:
  - name: appuser
    state: present
    shell: /bin/bash
    create_home: true
    password_lock: true
    groups:
      - "{{ linux_admin_group }}"
    append_groups: true
    passwordless_sudo: true
    authorized_keys:
      - "{{ lookup('file', ssh_key_dir + '/appuser.pub') }}"
    exclusive_keys: true
~~~
