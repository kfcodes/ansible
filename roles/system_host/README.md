# Role: system_host

Prepares service runtime hosts.

## Owns

- Docker/runtime package installation
- Docker service enablement
- Docker group membership for runtime users
- Application root directory creation, for example `/opt/apps`
- Optional host/runtime package installation

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

## Docker install modes

The role supports two Docker package modes.

### `distro`

Uses the operating system's package repositories.

Default on Debian-family hosts.

Debian-family default packages:

~~~yaml
system_host_docker_packages_debian_distro:
  - docker.io
  - docker-compose-plugin
~~~

RedHat-family distro fallback packages:

~~~yaml
system_host_docker_packages_redhat_distro:
  - docker
  - docker-compose-plugin
~~~

Use this when you want simple distro-managed Docker packages.

### `official`

Uses Docker's upstream package repository.

Default on RedHat/Fedora/Rocky-family hosts because distro Docker package availability is inconsistent across RedHat-family distributions.

RedHat/Fedora/Rocky official packages:

~~~yaml
system_host_docker_official_redhat_packages:
  - docker-ce
  - docker-ce-cli
  - containerd.io
  - docker-buildx-plugin
  - docker-compose-plugin
~~~

The role can also remove conflicting packages before installing Docker:

~~~yaml
system_host_docker_remove_conflicting_packages: true
~~~

## Important variables

General host/runtime variables:

- `system_host_packages`
- `system_host_packages_debian`
- `system_host_packages_redhat`
- `system_host_app_root`
- `system_host_app_root_owner`
- `system_host_app_root_group`
- `system_host_app_root_mode`
- `system_host_deploy_user`

Docker variables:

- `system_host_install_docker`
- `system_host_docker_install_packages`
- `system_host_docker_package_method`
- `system_host_docker_service_name`
- `system_host_docker_group`
- `system_host_docker_users`
- `system_host_manage_docker_service`

RedHat/Fedora/Rocky official Docker variables:

- `system_host_docker_redhat_manage_repo`
- `system_host_docker_redhat_repo_helper_package`
- `system_host_docker_redhat_repo_url`
- `system_host_docker_official_redhat_packages`
- `system_host_docker_remove_conflicting_packages`
- `system_host_docker_conflicting_packages`

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

## Example RedHat/Rocky override

~~~yaml
system_host_docker_package_method: official
system_host_docker_redhat_manage_repo: true
system_host_docker_remove_conflicting_packages: true
~~~

## Example Debian/Ubuntu override

~~~yaml
system_host_docker_package_method: distro
system_host_docker_packages_debian_distro:
  - docker.io
  - docker-compose-plugin
~~~

## Testing

The Molecule scenario validates Docker package selection and RedHat official Docker task flow without installing Docker.

Run:

~~~bash
cd roles/system_host
molecule test
~~~
