# Configuration Guide: Rclone Bidirectional Synchronization (Ubuntu -> Google Drive)

This document details the step-by-step process to create a local working folder with offline/online synchronization using `rclone` and automated via `systemd`.

## 1. Installation and Initial Configuration
Install the package on Ubuntu:
```bash
sudo apt update && sudo apt install rclone
```

Connect your Google Drive account:
```bash
rclone config
```
*(Menu answers: `n` for New remote > Name: `gdrive` > Storage: `drive` > Scope: `1` > Auto config: `y` > Log in in the browser).*

## 2. Folder Structure and First Synchronization
Create the local folder that will serve as a mirror of the cloud:
```bash
mkdir -p ~/GoogleDrive/Workspace
```

Perform the first synchronization. **Attention:** The `--resync` parameter should be used ONLY on this first time (or if the database becomes corrupted) to create the initial mapping:
```bash
rclone bisync "gdrive:Workspace" ~/GoogleDrive/Workspace --resync -P
```

## 3. Manual Shortcuts (Aliases) for Daily Use and Troubleshooting
Create quick shortcuts to pull cloud updates, mirror changes, or fix conflicts.

Open the terminal configuration file:
```bash
nano ~/.bashrc
```

Add the following lines at the end of the file:
```bash
# ---------------------------------------------------
# AUTOMAÇÃO DO GOOGLE DRIVE (RCLONE)
# ---------------------------------------------------

# 1 - Sincronização Bidirecional (Uso diário normal)
alias sync-drive="rclone bisync ~/GoogleDrive/Workspace gdrive:Workspace --progress"

# 2 - Espelhamento Unidirecional (O local sobrepõe a nuvem - espelho exato)
alias mirror-drive="rclone sync ~/GoogleDrive/Workspace gdrive:Workspace --progress"

# 3 - Sincronização de Emergência (Repara o banco de dados em caso de conflitos)
alias resync-drive="rclone bisync ~/GoogleDrive/Workspace gdrive:Workspace --resync --progress"
```
*(Note: Replace `~/GoogleDrive/Workspace` and `gdrive:Workspace` if your paths or remote names are different).* 

Reload the terminal to apply:
```bash
source ~/.bashrc
```

## 4. Send Automation (Systemd)
The goal here is to make the system silently send changes to the cloud whenever a file is saved/closed in the local folder.

**Step A: The Execution Script**
Create a hidden folder to store your scripts and create the file:
```bash
mkdir -p ~/.scripts
nano ~/.scripts/sync_rclone.sh
```

Paste the code below and save:
```bash
#!/bin/bash
rclone bisync "gdrive:Workspace" "$HOME/GoogleDrive/Workspace"
```

Give execution permission to the script:
```bash
chmod +x ~/.scripts/sync_rclone.sh
```

**Step B: The System "Watchdog" (Path Unit)**
Create the file that will monitor the folder:
```bash
mkdir -p ~/.config/systemd/user
nano ~/.config/systemd/user/gdrive-sync.path
```

Paste the code below and save:
```ini
[Unit]
Description=Monitors the Google Drive Workspace folder

[Path]
PathModified=%h/GoogleDrive/Workspace

[Install]
WantedBy=default.target
```

**Step C: The Service (Service Unit)**
Create the file that connects the trigger to your script:
```bash
nano ~/.config/systemd/user/gdrive-sync.service
```

Paste the code below and save:
```ini
[Unit]
Description=Executes Rclone synchronization

[Service]
Type=oneshot
ExecStart=%h/.scripts/sync_rclone.sh
```

**Step D: Activate Automation**
Reload the system manager and enable monitoring:
```bash
systemctl --user daemon-reload
systemctl --user enable --now gdrive-sync.path
```

## 5. Workflow Summary
* **Starting the day:** Open the terminal and type `sync-drive` to download anything that has been changed by your phone/cloud.
* **During work:** Just save your files normally (`Ctrl+S`). Systemd will take care of uploading changes to Google Drive in the background.
* **Fixing conflicts:** Use `resync-drive` if rclone reports database or sync errors (e.g., conflicts with specific files).
* **Forcing upload:** Use `mirror-drive` to force the cloud to match your local folder exactly, overriding cloud changes.