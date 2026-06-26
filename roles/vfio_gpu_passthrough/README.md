# Role: vfio_gpu_passthrough

Configures VFIO/GPU passthrough hosts.

## Owns

- IOMMU/VFIO kernel module configuration
- GRUB kernel command-line configuration
- Initramfs and GRUB handlers
- Optional VFIO helper scripts
- Optional VM/demo VM creation when explicitly enabled

## Does not own

- General base OS setup
- SSH hardening
- Docker
- Application deployment
- Kiosk sessions

Those responsibilities belong to `system_base`, `system_security`, `system_host`, `container_service`, and `kiosk_mode`.

## Expected host layer

Used by:

~~~text
vfio_hosts
~~~

through:

~~~text
playbooks/provision_hosts.yml
~~~

## Safety defaults

This role should stay safe-by-default:

- `vfio_allow_reboot: false`
- `vfio_create_vm: false`
- `vfio_create_demo_vm: false`
- `vfio_install_runtime_scripts: false`

Do not run this role on WSL.

## Variables

Important variables:

- `gpu_pci_ids`
- `gpu_bdf`
- `iommu_platform`
- `vfio_allow_reboot`
- `vfio_create_vm`
- `vfio_create_demo_vm`
- `vfio_install_runtime_scripts`

## Safe check-mode example

~~~bash
ansible-playbook playbooks/provision_hosts.yml --tags vfio --check -K \
  --limit dev_desktop \
  -e vfio_allow_reboot=false \
  -e vfio_create_demo_vm=false \
  -e vfio_create_vm=false \
  -e vfio_install_runtime_scripts=false
~~~
