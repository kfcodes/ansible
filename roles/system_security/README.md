# Role: system_security

Applies the shared security baseline for managed hosts.

## Owns

- SSH daemon hardening
- Firewall configuration
- Fail2ban when enabled
- Automatic update service/timer
- Security package installation

## Does not own

- Creating app directories
- Installing Docker
- Deploying services
- Creating kiosk sessions
- GitHub SSH setup
- App/runtime user business logic beyond the security-layer automation user

Those responsibilities belong to `system_host`, `container_service`, `kiosk_mode`, `system_dev`, and `user_account`.

## Expected host layer

Used by:

~~~text
secured_linux_hosts
~~~

through:

~~~text
playbooks/configure_security.yml
~~~

## OS-family behavior

Debian-family:

- Firewall: `ufw`
- SSH service: `ssh`
- Automatic updates: `unattended-upgrades`
- Admin group: `sudo`

RedHat/Fedora/Rocky-family:

- Firewall: `firewalld`
- SSH service: `sshd`
- Automatic updates: `dnf-automatic.timer`
- Admin group: `wheel`

## Variables

Important variables:

- `system_security_firewall_backend`
- `system_security_enable_firewall`
- `system_security_firewall_allow_ports`
- `system_security_manage_sshd`
- `system_security_ssh_service_name`
- `system_security_enable_fail2ban`
- `system_security_enable_unattended_upgrades`
- `system_security_auto_updates_package`

## Safety notes

Be careful when enabling the firewall on remote hosts.

Make sure SSH key access works before applying:

~~~bash
ansible-playbook playbooks/configure_security.yml --limit HOSTNAME
~~~

For brand-new hosts, bootstrap SSH first:

~~~bash
ansible-playbook playbooks/bootstrap_ssh_access.yml -k -K --limit HOSTNAME
~~~
