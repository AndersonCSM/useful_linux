# Setup Guide

This guide explains how to use the installer script in this folder and what to expect before and after running it.

## What the script does

`setup_updated.sh` prepares an Ubuntu-based workstation with the current toolset used in this repository. It:

- updates the system and base packages
- adds the external repositories needed for Brave, ASUS tools, GitHub CLI, and Node.js
- installs development runtimes such as Python 3, Node.js, OpenJDK 21, Maven, and PostgreSQL
- installs desktop applications through APT, Snap, and Flatpak
- creates shell aliases and helper functions in `~/.bash_aliases`
- creates a standard project folder structure under `~/Projects`
- enables the ASUS fan-curve systemd service

## Before you run it

Make sure the machine has:

- a working internet connection
- sudo access
- enough disk space for the selected desktop apps and development tools
- a fresh enough Ubuntu base to support the repositories used by the script

Recommended checks:

```bash
sudo apt update
sudo apt -y upgrade
```

## How to run it

From the `ScriptInstalation` folder:

```bash
chmod +x setup_updated.sh
sudo ./setup_updated.sh
```

If you prefer to inspect the file first:

```bash
less setup_updated.sh
```

## What gets installed

The script installs tools in three layers:

- APT for native Ubuntu packages and external APT repositories
- Snap for IDEs and a few desktop utilities that are still convenient there
- Flatpak for specialized desktop apps and sandboxed tools

The detailed tool list lives in [ConfigToolsApps.md](ConfigToolsApps.md).

## After the script finishes

The script prints a short checklist at the end. In practice, the next steps are:

1. Restart the machine.
2. Verify the main tool versions.
3. Configure Git identity if needed.
4. Add your SSH key for GitHub if you use GitHub over SSH.
5. Authenticate with `gh auth login`.

Useful verification commands:

```bash
code --version
git --version
java -version
python3 --version
node --version
npm --version
psql --version
```

## Shell helpers created by the script

The installer writes custom aliases and helper functions into `~/.bash_aliases` and sources it from `~/.bashrc` if needed.

Highlights:

- `gs`, `ga`, `gc`, `gp` for Git workflows
- `ll`, `update`, `install`, `remove` for system tasks
- `python`, `pip`, `node-version` for development checks
- `psql-start`, `psql-stop`, `psql-status`, `psql-restart` for PostgreSQL
- `mkproject` for creating project folders quickly
- `update-all` for refreshing APT and Snap

## Project folders

The script creates a default structure under `~/Projects`:

```text
Projects/
├── java/
├── python/
├── cpp/
├── csharp/
├── web/
├── scripts/
└── latex/
```

## Notes on versions

- Python is installed from Ubuntu as `python3`, `python3-pip`, and `python3-venv`.
- Java is pinned to `openjdk-21-jdk`.
- Node.js comes from NodeSource `setup_24.x`, which also provides npm.

## Troubleshooting

If the script stops early:

- rerun it after fixing the reported package or repository issue
- verify that the external repositories were added successfully
- check the end of the output for the package that failed

If a desktop app is already installed through another channel, the script may warn but continue.

## Short version

Run:

```bash
sudo ./setup_updated.sh
```

Then reboot and verify the environment.
