# Role: system_host

Prepares service runtime hosts.

## Owns

- Docker/runtime package installation
- Docker service enablement
- Docker group membership for runtime users
- Application root directory creation, for example `/opt/apps`

## Does not own

- SSH hardening
- Firewall configuration
- Fail2ban
- Automatic security updates
- Application deployment
- Kiosk sessions
- User SSH authorized keys

Those responsibilities belong to `system_security`, `container_service`, `kiosk_mode`, and `user_account`.

## Expected host layer

Used by:

~~~text
service_runtime_hosts
~~~

through:

~~~text
playbooks/provision_hosts.yml
~~~

## Variables

Important variables:

- `system_host_install_docker`
- `system_host_deploy_user`
- `system_host_docker_users`
- `system_host_app_root`
- `system_host_app_root_owner`
- `system_host_app_root_group`
- `system_host_app_root_mode`
- `system_host_docker_packages`

## OS support

Debian/Ubuntu support is the primary target.

Fedora/Rocky support should be added by branching Docker package/repository setup by `ansible_os_family`.

## Example usage

~~~yaml
---
- name: Provision service runtime hosts
  hosts: service_runtime_hosts
  gather_facts: true
  become: true

  tasks:
    - name: Configure service runtime
      ansible.builtin.include_role:
        name: system_host
~~~
