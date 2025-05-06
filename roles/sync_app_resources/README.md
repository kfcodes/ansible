# Ansible Role: sync_resources

This role synchronizes resource directories between remote and local systems using `ansible.posix.synchronize`, powered by `rsync`. It supports custom job definitions, robust failure handling, and customizable rsync options.

---

## Features

- Supports multiple sync jobs with flexible configuration
- Push or pull mode per job
- Customizable rsync options per job
- Error-tolerant with clear failure logging
- Summary of failed jobs at the end of play execution

---

## Role Variables

### `sync_jobs` (required)

A list of jobs to run, each containing:

```yaml
sync_jobs:
  - name: Sync DB backups
    src: /srv/db/backups/
    dest: /mnt/devsync/db/
    mode: pull
    rsync_opts:
      - "--archive"
      - "--progress"

  - name: Sync App Scripts
    src: /opt/scripts/
    dest: /mnt/devsync/scripts/

