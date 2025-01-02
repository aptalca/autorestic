# autorestic

This alpine based image contains the latest versions of restic and autorestic binaries, along with a cron service.

All necessary config resides under `/config`, which should be bind mounted on host.

Root crontab contains a (commented out) sample autorestic backup line but you can use a restic command instead.

**Important:**
The container must have a `hostname` defined in docker arguments because restic identifies snapshots by hostname.
