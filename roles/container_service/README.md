# Role: container_service

Deploys one or more containerized services.

## Owns

- Cloning or updating service repositories
- Rendering Dockerfiles when requested
- Rendering Docker Compose files
- Starting/recreating containers through Docker Compose
- Optional post-deploy health checks

## Does not own

- Installing Docker
- Creating runtime users
- Creating `/opt/apps`
- SSH/firewall/security hardening
- Backups

Those responsibilities belong to `system_host`, `user_account`, `system_security`, and `backup_sync`.

## Expected host layer

Use this role on hosts in service deployment groups such as:

- `frontend_service`
- `label_service`
- `database_service`
- `file_service`
- `manufacturing_service`
- `pallet_service`
- `product_service`

These groups are children of `service_deployment_targets`.

## Variables

Important variables:

- `service_name`
- `container_services`
- `container_service_root_path`
- `container_service_manage_runtime`
- `container_service_run_healthchecks`
- `container_service_manage_dockerfile`
- `container_service_default_networks`
- `container_service_healthcheck`

Service-specific variables are stored in:

~~~text
inventory/service_vars/
~~~

and loaded explicitly by `playbooks/deploy_services.yml`.

## OS support

Mostly OS-agnostic once Docker Compose is available.

Docker installation belongs to `system_host`.

## Example usage

~~~yaml
---
- name: Deploy label service
  hosts: label_service
  gather_facts: true
  become: true

  vars_files:
    - ../inventory/service_vars/label_service.yml

  tasks:
    - name: Deploy label containers
      ansible.builtin.include_role:
        name: container_service
~~~
