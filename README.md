# SPT Server

This creates hosting configuration for an SPT server on Fly.io.

## Setup

### Fly.io

> [!NOTE]  
> This guide assumes you have a Fly.io account and the `flyctl` CLI tool installed. If you don't have these, please refer to the [Fly.io documentation](https://fly.io/docs/getting-started/) for setup instructions.

First of all, pick a globally unique name for your server. This will be used as the subdomain for your server, e.g. `https://<SERVER NAME>.fly.dev`. Alternatively, omit it when creating the server and let Fly.io generate a random name for you.

Create an app on Fly.io:

```bash
flyctl apps create <SERVER NAME>
```

Update the `fly.toml` file with your server name:

```toml
app = "<SERVER NAME>"
```

Now deploy your app:

```bash
fly deploy
```

In the output, you will see a URL like `https://<SERVER NAME>.fly.dev` where your SPT server is now running. In your SPT launcher, you can now configure it to connect to `https://<SERVER NAME>.fly.dev:6969`.

### (Optional) GitHub Repository

If you want to use this repository as a template for your own SPT server, you can fork this repository and store any changes you make in your fork. This is optional, but recommended if you want to keep track of changes or contribute back to the original repository.

Login to GitHub and click on the fork-button on the top right of the page. This will create a copy of this repository in your GitHub account.

Alternatively, if you have the GitHub CLI installed, you can fork the repository using the following command:

```bash
gh repo fork Addono/spt-server
```

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
