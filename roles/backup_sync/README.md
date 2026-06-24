# Ansible Role: backup_sync

This role manages generic backup and synchronization workflows.

It supports two separate workflows:

1. **Immediate sync jobs** using `ansible.posix.synchronize` / `rsync`
2. **Scheduled backup jobs** by installing scripts and configuring cron

---

## Responsibilities

This role is responsible for:

- Running backup/sync jobs immediately
- Pulling or pushing files with rsync
- Installing backup scripts
- Creating cron jobs for recurring backups
- Reporting failed sync jobs

This role is not responsible for:

- Docker installation
- Container deployment
- User account creation
- SSH login/bootstrap access
- Base package installation

---

## Variables

### `backup_sync_jobs`

A list of sync jobs to run when the playbook runs.

Legacy variable `sync_jobs` is still supported, but `backup_sync_jobs` is preferred.

```yaml
backup_sync_jobs:
  - name: Pull database backups
    src: /srv/db/backups/
    dest: /home/m/backups/db/
    mode: pull
    rsync_opts:
      - "--archive"
      - "--compress"
