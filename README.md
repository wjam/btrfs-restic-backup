# btrfs-restic-backup

A systemd-based tool to back up a BTRFS subvolume using Restic.

- [systemd](https://systemd.io/): because it's the Linux standard
- [BTRFS](https://btrfs.readthedocs.io/): it's baked into Linux and allows creating snapshots of volumes to use as a basis for backing up
- [Restic](https://restic.net/): supports a large number of destinations

> [!NOTE]
> This backup solution makes use of `PrivateMounts` so that the BTRFS mount can be replaced to work around [a Restic issue](https://github.com/restic/restic/issues/2714). For this solution to work, BTRFS must be used in the ['flat' layout style](https://archive.kernel.org/oldwiki/btrfs.wiki.kernel.org/index.php/SysadminGuide.html#Flat).

This backup tool makes use of BTRFS snapshots to ensure the backup comes from a "consistent view" of the files. This means the backup can work both for 'normal' files, such as backing up music, as well as for databases:

> An alternative file-system backup approach is to make a “consistent snapshot” of the data directory, if the file system supports that functionality (and you are willing to trust that it is implemented correctly). The typical procedure is to make a “frozen snapshot” of the volume containing the database, then copy the whole data directory (not just parts, see above) from the snapshot to a backup device, then release the frozen snapshot. This will work even while the database server is running. However, a backup created in this way saves the database files in a state as if the database server was not properly shut down; therefore, when you start the database server on the backed-up data, it will think the previous server instance crashed and will replay the WAL log. This is not a problem; just be aware of it (and be sure to include the WAL files in your backup). You can perform a CHECKPOINT before taking the snapshot to reduce recovery time.

From https://www.postgresql.org/docs/current/backup-file.html.

## Installation

> [!TIP]
> Given you want to keep to the [3-2-1 backup strategy](https://www.backblaze.com/blog/the-3-2-1-backup-strategy/), these units are [template unit files](https://fedoramagazine.org/systemd-template-unit-files/) so that backups can be run against multiple repository locations.

> [!NOTE]
> Example commands assume the use of [Hetzner storage box](https://www.hetzner.com/storage/storage-box/).

1. Install `restic`
    ```shell
    sudo apt update && sudo apt install restic
    ```
2. Copy the contents of [./scripts](./scripts) to `/usr/local/bin`
3. Copy the contents of [./systemd](./systemd) to `/usr/local/lib/systemd/system/`
4. Create drop-in directories for configuration
    ```shell
    sudo mkdir /usr/local/lib/systemd/system/btrfs-restic-backup@NAME.service.d
    ```
5. Populate drop-in file at `/usr/local/lib/systemd/system/btrfs-restic-backup@NAME.service.d/env.conf` with specific configuration, such as:
    ```unit file (systemd)
    [Service]
    Environment="BTRFS_SUBVOL=/usr/local/path"
    Environment="BACKUP_PATHS=/usr/local/path"
    Environment="RESTIC_REPOSITORY=sftp://user@user.your-storagebox.de:23/name"
    Environment="RESTIC_PASSWORD=the-password-for-the-repo"
    Environment="RESTIC_OPTIONS=--option=sftp.args='-i/path/to/ssh/key'"
    ```
6. Initialise the new Restic repository, assuming it is new
    ```shell
    restic init --option=sftp.args='-i/path/to/ssh/key' --repo sftp://user@user.your-storagebox.de:23/name init
    ```
7. Enable the new backup
    ```shell
    sudo systemctl daemon-reload
    sudo systemctl enable btrfs-restic-backup@NAME.service
    sudo systemctl enable btrfs-restic-backup@NAME.timer
    sudo systemctl start btrfs-restic-backup@NAME.timer
    ```

> [!TIP]
> You may wish to add a `RequiresMountsFor=/usr/local/path` to the drop-in file so that the service only gets run once the BTRFS device is mounted.

## Getting notified if the back up fails

As systemd supports 'drop-in' directories (e.g. `/usr/local/lib/systemd/system/btrfs-restic-backup.service.d@NAME`), an [`OnFailure` option](https://www.freedesktop.org/software/systemd/man/latest/systemd.unit.html#OnFailure=) can be added to notify any service if something goes wrong.

`ExecStartPre` and `ExecStopPost` can also be used to [integrate with healthchecks.io](https://healthchecks.io/docs/monitoring_systemd_tasks/) using a drop-in file to `/usr/local/lib/systemd/system/btrfs-restic-backup.service.d@NAME/healthcheck.conf` like this:

```unit file (systemd)
[Service]
ExecStartPre=-curl -sS -m 10 --retry 5 https://hc-ping.com/your-uuid-here/start
ExecStopPost=curl -sS -m 10 --retry 5 https://hc-ping.com/your-uuid-here/${EXIT_STATUS}
```

## TODO list
- Separate systemd unit running verify? How would you stop the two units from running at the same time?
- Add a test to verify `ExecStopPost` behaves as expected?
