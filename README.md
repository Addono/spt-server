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

Currently, the GitHub Actions are set up to run daily at 00:00 UTC. To change this, edit the `schedule` in [`.github/workflows/backup-profiles.yml`](.github/workflows/backup-profiles.yml). To test it, you can manually dispatch it.