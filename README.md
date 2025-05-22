# SPT Server

This repository helps creating and managing an SPT server on [Fly.io](https://fly.io).

## Table of Contents
- [What's Included](#whats-included)
- [Setup](#setup)
  - [Fly.io](#flyio)
  - [GitHub Repository](#optional-github-repository)
  - [GitHub Actions](#optional-github-actions)
    - [Backups](#backups)
- [Cost](#cost)

## What's Included

This repository provides a simple setup for hosting a modded SPT (Single Player Tarkov) server on Fly.io. It automates deployment, mod management, scaling, and backups, making it easy to run and maintain a custom Tarkov server in the cloud with minimal manual intervention and on a budget.

Among other things, it includes:

- **Fly.io deployment configuration**: Pre-configured `fly.toml` and Dockerfile to deploy the SPT server to Fly.io, including automatic scale-to-zero when no users are connected to the server.
- **Automated mod installation**: Installs a curated set of mods automatically from URLs defined in `fly.toml`.
- **Custom mod configuration**: Example custom configs for mods (e.g., SVM and Lotus) included in the `mount/` directory. This config is automatically copied to the server on deployment, making it easier to manage it from Git and avoiding the need to SSH into the server.
- **Automated Startup Modifications**: Handles mod setup, applying config stored in Git, and applies Linux compatibility fixes on container start.
- **Automated Backups**: Daily backups of player profiles using GitHub Actions, storing them as artifacts in the repository. This allows you to restore player profiles in case of profile corruption or data loss.
- **Remote Deploys**: Deploys can either be triggered locally or remotely via GitHub Actions, allowing you to manage the server from anywhere.

## Setup

### Fly.io

> [!NOTE]  
> This guide assumes you have a Fly.io account and the `flyctl` CLI tool installed. If you don't have these, please refer to the [Fly.io documentation](https://fly.io/docs/getting-started/) for setup instructions.

First of all, pick a globally unique name for your server. This will be used as the subdomain for your server, e.g. `https://<SERVER NAME>.fly.dev`. Alternatively, omit it when creating the server and let Fly.io generate a random name for you.

Create an app on Fly.io:

```bash
flyctl apps create <SERVER NAME>
```

Update the `fly.toml` file with your server name, add a new line:

```toml
app = "<SERVER NAME>"
```

Now deploy your app:

```bash
fly deploy
```

In the output, you will see a URL like `https://<SERVER NAME>.fly.dev` where your SPT server is now running. In your SPT launcher, you can now configure it to connect to `https://<SERVER NAME>.fly.dev:6969`.

Clients with ModSync installed will automatically download all required mods on boot, as such it's highly recommended that all clients do this.

After the first deployment, it is important to check whether all mods have been successfully downloaded and extracted. You can do this by SSHing into the server and checking the folder `./mod_downloads/remains`:

```bash
❯ fly ssh console
Connecting to <your server IP>... complete
root@<machine ID>:/opt/server# cd mod_download/remains/
```
Any files in this folder are mods that have not been successfully downloaded or extracted. Manually move them to the `./mods` folder to make them available to the server. For more information on how to manage mods, see [fika-spt-server-docker](https://github.com/zhliau/fika-spt-server-docker?tab=readme-ov-file#-running) documentation.


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

## Cost

This setup is designed to be budget-friendly. The pricing model of Fly.io is pay-per-use. In addition, the server will scale to zero when no users are connected, meaning you only pay for the time the server is actually running.

You can tweak the resources available to the server in the `fly.toml` file, for example, by changing the `vm.memory` and `vm.cpus` settings. The default settings are usually sufficient for a small SPT server with a few players.

The only constant-cost would be storage, which is a couple of cents per GB per month.

In our experiences, our bill has been around $2-3 a month. Fly.io typically doesn't invoice you for bills under $5 each month, thus the server has effectively been free.
