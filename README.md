# SPT Server

This creates hosting configuratiopn for an SPT server on Fly.io.

## Setup

### Fly.io

*To be added*

### (Optional) GitHub Actions

GitHub Actions is an optional tool to automate some tasks, currently only for creating backups. To use it, you need to set up the following secrets:

```bash
flyctl tokens create deploy | gh secret set FLY_API_TOKEN
```

Alternatively to creating it through the CLI, create a deploy token manually and set it as `FLY_API_TOKEN` in the repository secrets.


#### Backups

The GitHub Action for creating backups is configured to, on a schedule, pull down all the profiles from the SPT server and storing those in GHA artifacts.

**Retention** Artifacts are **not** retained permanently, the retention period can be configured (30 days by default, although it can be updated to 90 days). To access the backups, open the latest run of the backup profile workflow and download the artifacts.

**Schedule**: Backups run daily at 00:00 UTC. To change this, edit the `schedule` in [`.github/workflows/backup-profiles.yml`](.github/workflows/backup-profiles.yml). 

**Testing** To test the action instead of waiting for the schedule to kick-in, you can manually dispatch it.
