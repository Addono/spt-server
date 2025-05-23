# SPT Server on Fly.io

This repository helps creating and managing an SPT server on [Fly.io](https://fly.io).

## Table of Contents
- [SPT Server](#spt-server)
  - [Table of Contents](#table-of-contents)
  - [What's Included](#whats-included)
  - [Setup](#setup)
    - [(Optional) GitHub Repository](#optional-github-repository)
    - [Fly.io](#flyio)
    - [(Optional) GitHub Actions](#optional-github-actions)
      - [Backups](#backups)
  - [Cost](#cost)
  - [Customizing Your Server](#customizing-your-server)
    - [Adding or Removing Mods](#adding-or-removing-mods)
    - [Changing the SPT Version](#changing-the-spt-version)
    - [Changing the Fika Version](#changing-the-fika-version)
    - [Changing Server Resources and Provisioning](#changing-server-resources-and-provisioning)
      - [Adjusting Resources (CPU \& Memory)](#adjusting-resources-cpu--memory)
      - [Always-On vs. Scale-to-Zero](#always-on-vs-scale-to-zero)
      - [Enabling Swap (Extra Memory)](#enabling-swap-extra-memory)
  - [References](#references)

## What's Included

This repository provides a simple setup for hosting a modded SPT (Single Player Tarkov) server on Fly.io. It automates deployment, mod management, scaling, and backups, making it easy to run and maintain a custom Tarkov server in the cloud with minimal manual intervention and on a budget.

Among other things, it includes:

- 🚀 **Fly.io deployment configuration**: Pre-configured `fly.toml` and Dockerfile to deploy the SPT server to Fly.io, including automatic scale-to-zero when no users are connected to the server.
- 🛠️ **Automated mod installation**: Installs a curated set of mods automatically from URLs defined in `fly.toml`.
- ⚙️ **Custom mod configuration**: Example custom configs for mods (e.g., SVM and Lotus) included in the `mount/` directory. This config is automatically copied to the server on deployment, making it easier to manage it from Git and avoiding the need to SSH into the server.
- 🔄 **Automated Startup Modifications**: Handles mod setup, applying config stored in Git, and applies Linux compatibility fixes on container start.
- 💾 **Automated Backups**: Daily backups of player profiles using GitHub Actions, storing them as artifacts in the repository. This allows you to restore player profiles in case of profile corruption or data loss.
- 🌐 **Remote Deploys**: Deploys can either be triggered locally or remotely via GitHub Actions, allowing you to manage the server from anywhere.

And probably the best part, it's really cheap! See the [Cost](#cost) section for more details, but spoiler: my bill has been waived every month so far as it never goes over $5. 💸

## Setup

### (Optional) GitHub Repository

> [!NOTE]
> In case you do not want to use GitHub, you can just download this repository and work on it locally:
>
> <img width="200" alt="image" src="https://github.com/user-attachments/assets/71be58ec-8491-4742-a041-87e69cf04d78" />
>
> Skip this step and go straight to the step on [deploying to Fly.io](#flyio). 


If you want to use this repository as a template for your own SPT server, you can fork this repository and store any changes you make in your fork. Using GitHub (or Git in general) is optional, but recommended if you want to keep track of changes or contribute back to the original repository.

Login to GitHub and click on the fork-button on the top right of the page. This will create a copy of this repository in your GitHub account. 

<img width="333" alt="image" src="https://github.com/user-attachments/assets/b549f636-7304-43c3-8c0d-646f7931ea97" />

Alternatively, if you have the GitHub CLI installed, you can fork the repository using the following command:

```bash
gh repo fork Addono/spt-server
```

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

## Customizing Your Server

You can easily customize your SPT server setup to fit your needs. Here are the main ways to tailor your deployment:

### Adding or Removing Mods

To add or remove mods, edit the `MOD_URLS_TO_DOWNLOAD` environment variable in your `fly.toml` file. This variable contains a list of mod download URLs. Simply add new URLs (one per line) to install more mods, or remove lines to exclude mods you don't want. Changes will take effect on the next deployment.

- **File:** `fly.toml`
- **Section:** `[env]` → `MOD_URLS_TO_DOWNLOAD`

### Changing the SPT Version

The SPT version is determined by the Docker image specified in your `Dockerfile`. To change the SPT version, update the image tag in the `FROM` line. For example:

```
FROM ghcr.io/zhliau/fika-spt-server-docker:3.11.3
```

Replace `3.11.3` with the desired version. See the [fika-spt-server-docker releases](https://github.com/zhliau/fika-spt-server-docker/pkgs/container/fika-spt-server-docker) for available tags.

- **File:** `Dockerfile`
- **Line:** `FROM ghcr.io/zhliau/fika-spt-server-docker:<version>`

### Changing the Fika Version

The Fika version is set in the `FIKA_VERSION` environment variable in your `fly.toml` file. To use a different version, change the value of `FIKA_VERSION`:

```
FIKA_VERSION = 'v2.4.8'
```

Replace `'v2.4.8'` with the version you want. Make sure the version is compatible with your chosen SPT version.

- **File:** `fly.toml`
- **Section:** `[env]` → `FIKA_VERSION`

### Changing Server Resources and Provisioning

You can further customize how your SPT server is provisioned on Fly.io by editing the `fly.toml` file. This allows you to balance cost, performance, and availability according to your needs.

#### Adjusting Resources (CPU & Memory)

The `[vm]` section in `fly.toml` controls the amount of memory and CPU allocated to your server:

```toml
[vm]
  memory = '3gb'   # Increase for better performance, decrease to save cost
  cpu_kind = 'shared' # Can be 'shared' or 'performance' (dedicated)
  cpus = 2        # Number of CPU cores
```
- **More resources** improve server performance, especially with many mods or players, but increase cost.
- **Fewer resources** reduce cost but may impact performance.

#### Always-On vs. Scale-to-Zero

By default, the server is configured to scale to zero (suspend) when not in use, minimizing costs:

```toml
[http_service]
  auto_stop_machines = "suspend"  # Scale to zero when idle
  min_machines_running = 0         # No always-on machines
```
- **To keep the server always on**, set `auto_stop_machines` to `false` and `min_machines_running` to `1`:
  ```toml
  [http_service]
    auto_stop_machines = false
    min_machines_running = 1
  ```
- **Tradeoff:** Always-on servers are more responsive but incur higher costs, as you pay for uptime even when no one is playing.

#### Enabling Swap (Extra Memory)

You can enable swap to provide extra (slower) memory, which can help avoid out-of-memory errors without increasing RAM size:

```toml
# swap_size_mb = 1024  # Enable for 1GB swap (uncomment to use)
```
- **Note:** Swap is not compatible with scale-to-zero (suspend mode). Only enable swap if your server is always on.
- **Tradeoff:** Swap is slower than RAM but can prevent crashes due to memory exhaustion. Useful for mod-heavy servers.

## References

- [Fly.io Documentation](https://fly.io/docs/reference/configuration/)
- [fika-spt-server-docker GitHub Repository](https://github.com/zhliau/fika-spt-server-docker)
- [Fika Project Wiki](https://project-fika.gitbook.io/wiki)
- [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)
- [Bash Scripting Guide](https://www.gnu.org/software/bash/manual/bash.html)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [TOML Language Documentation](https://toml.io/en/)
- [Linux Command Line Basics](https://ubuntu.com/tutorials/command-line-for-beginners)

For more details, see the comments in `fly.toml` and the rest of this README and codebase for configuration and customization options.
