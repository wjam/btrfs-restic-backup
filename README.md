# btrfs-restic-backup

A systemd-based tool to back up a BTRFS subvolume using restic.

- systemd: because it's the Linux standard
- BTRFS: it's baked into Linux and allows creating snapshots of volumes to use as a basis for backing up
- BTRFS 'flat' layout: allows replacement of the separate mounts - required because of https://github.com/restic/restic/issues/2714
- restic: supports a large number of destinations

[//]: # (TODO: include 'flat' in the repo name?)

## TODO list
- Get a licence for the code - unlicence?
- separate systemd unit running verify?
- notify on backup failure - https://northernlightlabs.se/2014-07-05/systemd-status-mail-on-unit-failure.html
  - Send notification to NTFY?
  - "dead man's switches"
    - https://healthchecks.io/docs/monitoring_systemd_tasks/ (free up to 20 jobs) (OS code at https://github.com/healthchecks/healthchecks)
    - https://cronitor.io/docs/heartbeat-monitoring (free for 5 'monitors')
- Documentation
  - limitations - requires 'flat' BTRFS subvolume
  - how to override settings for restic - '.d' directory containing overrides
  - how to install this stuff
  - Units should be usable with a destination of a local filesystem as well as an S3-like remote store (e.g. Backblaze).

## Ideas

- Document how settings should be set - i.e. a '.d' directory containing overrides for environment variables.
- Create systemd units and scripts similar to https://blog.vsq.cz/blog/atomic-backups-with-restic-and-btrfs/
