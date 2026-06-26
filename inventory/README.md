# Inventory Layout

This inventory is split by responsibility.

## `hosts.yml`

Defines host membership and group hierarchy.

Current top-level groups:

- `managed_linux_hosts`
  - All Linux machines managed by Ansible.
  - Receives common base OS configuration through `system_base`.

- `secured_linux_hosts`
  - Machines that receive the shared security baseline.
  - Includes service runtime hosts and kiosk display hosts.
  - Used by `configure_security.yml`.

- `service_runtime_hosts`
  - Machines that run containers/services.
  - Receives Docker/runtime setup through `system_host`.

- `kiosk_display_hosts`
  - Machines used as kiosk/browser display clients.
  - Receives kiosk session and autologin setup through `kiosk_mode`.

- `dev_control_hosts`
  - Local development/control-node machines.
  - Receives dev tooling and GitHub SSH setup through `system_dev`.

- `service_deployment_targets`
  - Parent group for deployable service groups.
  - Includes groups such as `frontend_service`, `label_service`, and `database_service`.

- `vfio_hosts`
  - Hosts that receive GPU passthrough configuration.

## `group_vars/`

Variables loaded automatically by Ansible based on inventory group name.

Files must match group names from `hosts.yml`.

Examples:

- `managed_linux_hosts.yml`
- `secured_linux_hosts.yml`
- `service_runtime_hosts.yml`
- `kiosk_display_hosts.yml`
- `dev_control_hosts.yml`
- `service_deployment_targets.yml`

## `host_vars/`

Per-machine settings.

Use this for host-specific values such as:

- `host_ip`
- `system_hostname`
- static network configuration
- per-host overrides

## `service_vars/`

Service deployment variables.

These are intentionally not stored in `group_vars/` because hosts such as `aoife` and `laura` belong to multiple service groups. Keeping service variables in `group_vars/` causes variable collisions.

`service_vars/` files are loaded explicitly by `playbooks/deploy_services.yml`.

Examples:

- `frontend_service.yml`
- `label_service.yml`
- `database_service.yml`

## Bootstrap note

First-time SSH setup is handled separately by:

~~~bash
ansible-playbook playbooks/bootstrap_ssh_access.yml -k -K
~~~

Normal provisioning assumes the long-term deploy user and SSH key already work.
