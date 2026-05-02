# Installation Documentation: Analog Simulation Environment on Linux (Ubuntu)

This document describes the procedures used to configure a robust environment for electrical circuit simulation and design on Ubuntu, keeping versions frozen to avoid project breakage caused by automatic updates.

## Index

- [Installation Documentation: Analog Simulation Environment on Linux (Ubuntu)](#installation-documentation-analog-simulation-environment-on-linux-ubuntu)
  - [Index](#index)
  - [Tool Description](#tool-description)
  - [1. Ngspice Installation (Simulation Engine)](#1-ngspice-installation-simulation-engine)
  - [2. Qucs-s Installation (Graphical Interface)](#2-qucs-s-installation-graphical-interface)
  - [3. KiCad Installation (Schematics and PCB)](#3-kicad-installation-schematics-and-pcb)

## Tool Description

- **Ngspice**: Text-based SPICE simulation engine. It is responsible for numerical circuit analysis (DC, AC, transient, and others).
- **Qucs-s**: Graphical interface for schematic drawing and simulation setup. It uses Ngspice as the backend simulator.
- **KiCad**: EDA suite for schematic capture and PCB layout. It is used to design boards and generate manufacturing files.
- **apt / apt install**: Ubuntu package management tools used to install software and dependencies.
- **apt-mark hold**: Command used to freeze a package version and prevent automatic updates during system upgrades.

## 1. Ngspice Installation (Simulation Engine)

Ngspice provides the mathematical simulation engine and should have its version frozen.

```bash
sudo apt update
sudo apt install ngspice
sudo apt-mark hold ngspice
```

## 2. Qucs-s Installation (Graphical Interface)

Since the interface was removed from recent official repositories, installation is done manually using the official `.deb` package.

```bash
# Download the static .deb package
wget https://github.com/ra3xdh/qucs-s/releases/download/24.3.0/qucs-s_24.3.0-1_amd64.deb

# Install and resolve dependencies
sudo apt install ./qucs-s_24.3.0-1_amd64.deb
```

Qucs-s automatically detects the Ngspice binary at `/usr/bin/ngspice`.

## 3. KiCad Installation (Schematics and PCB)

Install using the standard `.deb` package from Ubuntu native repositories.

```bash
sudo apt install kicad
```
