# ConfigToolsApps

This document lists the tools used by the installer and describes what each one is for.

## APT Packages

### Core system and utilities

- `git` - Distributed version control system used for local and remote code history.
- `nano` - Simple terminal editor for quick configuration edits.
- `htop` - Interactive process viewer for monitoring CPU, memory, and tasks.
- `unzip` - Extracts ZIP archives from the terminal.
- `putty` - SSH/Telnet client and terminal utility.
- `gparted` - Graphical partition editor for disks and storage devices.
- `psensor` - Hardware sensor monitor for temperatures and fan readings.
- `fwupd` - Firmware update framework for supported devices.

### Build and development stack

- `build-essential` - Basic compilation toolchain including GCC, make, and standard headers.
- `gdb` - GNU debugger for native applications.
- `make` - Build automation tool for projects with Makefiles.
- `cmake` - Cross-platform build system generator.
- `maven` - Java build and dependency manager.
- `python3` - Python 3 runtime used for scripting and automation.
- `python3-pip` - Python package installer for third-party libraries.
- `python3-venv` - Built-in Python virtual environment support.
- `nodejs` - JavaScript runtime used for web tooling and scripts.
- `openjdk-21-jdk` - Java 21 development kit for compiling and running Java applications.
- `postgresql` - PostgreSQL database server.
- `postgresql-contrib` - Extra PostgreSQL extensions and utilities.
- `gh` - GitHub CLI for repository and authentication workflows.

### Tools that require user configuration

- `gh` - After installation, run `gh auth login` to connect the CLI to your GitHub account.
- `postgresql` - After installation, create users/databases and set credentials according to your project needs.
- `python3` - May require virtual environments and pip package installation for each project.
- `nodejs` - Often needs project-local dependencies installed with `npm install`.
- `openjdk-21-jdk` - Usually needs `JAVA_HOME` and related environment variables if you work outside the default shell setup.

### Example configuration commands

#### GitHub CLI

```bash
gh auth login
gh repo clone owner/repository
gh issue list
```

#### PostgreSQL

```bash
sudo systemctl start postgresql
sudo -u postgres psql
CREATE USER myuser WITH PASSWORD 'strong-password';
CREATE DATABASE mydb OWNER myuser;
\q
```

#### Python 3

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install requests pytest
```

#### Node.js and npm

```bash
npm init -y
npm install express
npm install --save-dev eslint
```

#### Java 21

```bash
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"
java -version
```

### ASUS and hardware integration

- `asusctl` - Control utility for ASUS laptop performance profiles and fans.
- `supergfxctl` - Switchable graphics manager for supported ASUS devices.
- `rog-control-center` - ASUS ROG control center interface.

### Desktop applications via APT

- `brave-browser` - Privacy-focused web browser from Brave's APT repository.
- `gimp` - Advanced image editor for editing and compositing graphics.
- `libreoffice` - Full office suite for documents, spreadsheets, and presentations.
- `vlc` - Media player for most audio and video formats.
- `steam` - Game distribution and launcher platform.
- `retroarch` - Multi-system emulator frontend for games and consoles.
- `obs-studio` - Screen recording and live streaming software.
- `kicad` - PCB design suite for electronics projects.
- `arduino` - IDE for Arduino boards and embedded development.
- `okular` - Flexible document and PDF viewer.
- `gnome-boxes` - Virtual machine manager for GNOME desktops.
- `texstudio` - LaTeX editor for scientific and technical writing.
- `gnome-firmware` - GNOME firmware utility for supported hardware.

### GNOME and desktop experience

- `gnome-shell-extension-manager` - Installs and manages GNOME Shell extensions.
- `gnome-tweaks` - Adjusts GNOME appearance and behavior beyond default settings.

## Snap Packages

- `code` - Visual Studio Code, the main general-purpose IDE in the script.
- `intellij-idea-community` - JetBrains Java IDE for larger Java projects.
- `sublime-text` - Lightweight text editor for quick edits.
- `dbeaver-ce` - Database client for browsing and querying multiple engines.
- `postman` - API testing and request client.
- `discord` - Communication app for chat and calls.
- `thunderbird` - Desktop email client and organizer.
- `firefox` - Mozilla Firefox browser.

## Flatpak Packages

- `com.github.reds.LogisimEvolution` - Logic circuit designer for digital electronics exercises.
- `com.heroicgameslauncher.hgl` - Launcher for Epic Games and GOG libraries.
- `com.usebottles.bottles` - Windows compatibility manager built around Wine.
- `com.stremio.Stremio` - Media streaming application.
- `com.github.marhkb.Pods` - Container management app for Podman workflows.
- `com.github.tchx84.Flatseal` - Permissions manager for Flatpak applications.
- `hub.astralvixen.geforce-infinity` - NVIDIA-oriented utility app.
- `io.github.ilya_zlobintsev.LACT` - GPU tuning and control utility, especially useful for AMD systems.

## What moved to APT from other channels

These tools now live in the APT section because the script prefers native packages where possible:

- `brave-browser`
- `gimp`
- `libreoffice`
- `vlc`
- `steam`
- `retroarch`
- `obs-studio`
- `kicad`
- `arduino`
- `okular`
- `gnome-boxes`
- `texstudio`
- `gnome-firmware`

## Runtime notes

- Python uses the Ubuntu `python3` line together with `pip` and virtual environments.
- Java is fixed to `openjdk-21-jdk`.
- Node.js is installed from NodeSource `setup_24.x`, which includes npm.

## User setup reminders

- GitHub: authenticate with `gh auth login` and add your SSH key if you use SSH remotes.
- PostgreSQL: create the first database user, set passwords, and enable the service if you want it available on boot.
- Python and Node.js: initialize project-specific environments and dependency files per project instead of installing everything globally.

## Useful package commands

### APT

Install:

```bash
sudo apt install package-name
```

Update package lists and upgrade:

```bash
sudo apt update
sudo apt upgrade -y
```

Remove:

```bash
sudo apt remove package-name
sudo apt autoremove -y
```

Search and inspect:

```bash
apt search keyword
apt policy package-name
```

### Snap

Install:

```bash
sudo snap install package-name
```

Update:

```bash
sudo snap refresh
```

Remove:

```bash
sudo snap remove package-name
```

List installed snaps:

```bash
snap list
```

### Flatpak

Install:

```bash
sudo flatpak install flathub app.id
```

Update:

```bash
flatpak update
```

Remove:

```bash
flatpak uninstall app.id
```

List installed apps:

```bash
flatpak list --app
```

## Scripts and helpers created by the setup

The installer creates or updates a few user-facing helpers. They are meant to be edited later if you want to customize your workstation.

### `~/.bash_aliases`

Purpose: custom shell aliases and helper functions for Git, PostgreSQL, system tasks, and project folders.

How to use:

```bash
source ~/.bash_aliases
```

How to create or update:

```bash
nano ~/.bash_aliases
```

How to delete:

```bash
rm ~/.bash_aliases
```

If you delete it, remove the sourcing block from `~/.bashrc` too.

### ASUS fan service

File: `/etc/systemd/system/asus-fan-apply.service`

Purpose: applies the Asusctl Balanced profile after boot.

How to use:

```bash
sudo systemctl daemon-reload
sudo systemctl enable asus-fan-apply.service
sudo systemctl start asus-fan-apply.service
sudo systemctl status asus-fan-apply.service
```

How to create or update:

```bash
sudo nano /etc/systemd/system/asus-fan-apply.service
sudo systemctl daemon-reload
sudo systemctl restart asus-fan-apply.service
```

How to delete:

```bash
sudo systemctl disable asus-fan-apply.service
sudo rm /etc/systemd/system/asus-fan-apply.service
sudo systemctl daemon-reload
```

### Project folders

Folder: `~/Projects`

Purpose: standard workspace layout created by the setup script.

How to use:

```bash
cd ~/Projects
ls
```

How to create a new project folder:

```bash
mkdir -p ~/Projects/web/my-app
```

How to update the layout:

```bash
mkdir -p ~/Projects/{java,python,cpp,csharp,web,scripts,latex}
```

How to delete a folder:

```bash
rm -rf ~/Projects/web/my-app
```

Be careful with `rm -rf` and verify the path before running it.

## Source of truth

The installer logic lives in [setup_updated.sh](setup_updated.sh).