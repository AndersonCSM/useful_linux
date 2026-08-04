#!/bin/bash

# Ubuntu Environment Setup - Debian Base
# Updated to match the current toolset

set -e
echo "Starting the full Ubuntu environment setup..."

# 1. Base update and repository support
echo "--> Updating base packages..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget apt-transport-https software-properties-common flatpak gnome-software-plugin-flatpak

# Add Flathub (Flatpak repository)
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# 2. Third-party repositories
echo "--> Configuring third-party repositories..."

# Node.js current stable line as of Jan/2026 (includes npm)
curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -

# Brave Browser
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list

# ASUS Linux (asusctl, supergfxctl, rog-control-center)
sudo add-apt-repository ppa:asus-linux/asusctl -y

# GitHub CLI
sudo mkdir -p -m 755 /etc/apt/keyrings 2>/dev/null || true
wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# Visual Studio Code
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/packages.microsoft.gpg > /dev/null
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

# Sublime Text
wget -qO- https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/keyrings/sublimehq-archive.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/sublimehq-archive.gpg] https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list > /dev/null

sudo apt update

# 3. Core tools, Python, Node.js, JDK, and PostgreSQL
echo "--> Installing compilers, Python, Node.js, JDK, and PostgreSQL..."
sudo apt install -y build-essential gdb make cmake python3 python3-pip python3-venv nodejs openjdk-21-jdk maven postgresql postgresql-contrib gh asusctl supergfxctl rog-control-center

# 4. APT applications (system, tools, utilities)
echo "--> Installing applications via APT..."
APT_PACKAGES=(
    git
    nano
    htop
    unzip
    putty
    brave-browser
    gnome-shell-extension-manager
    gnome-tweaks
    gparted
    psensor
    fwupd
    gimp
    libreoffice
    vlc
    steam
    retroarch
    obs-studio
    kicad
    arduino
    okular
    gnome-boxes
    texstudio
    gnome-firmware
    code
    sublime-text
)

sudo apt install -y "${APT_PACKAGES[@]}"

# Set Brave as the system default browser
xdg-settings set default-web-browser brave-browser.desktop || true

# 5. Flatpak installs (desktop and specialized applications)
echo "--> Installing applications via Flatpak..."

install_flatpak() {
    local app_id=$1
    local app_display=$2
    echo "--> Installing ${app_display}..."
    if sudo flatpak install -y flathub "$app_id" 2>/dev/null; then
        echo "✓ ${app_display} installed successfully"
    else
        echo "⚠ Warning: ${app_display} is already installed or an error occurred"
    fi
}

install_flatpak "com.github.reds.LogisimEvolution" "Logisim Evolution"
install_flatpak "com.heroicgameslauncher.hgl" "Heroic Games Launcher"
install_flatpak "com.usebottles.bottles" "Bottles (Windows Emulation)"
install_flatpak "com.stremio.Stremio" "Stremio"
install_flatpak "com.github.marhkb.Pods" "Pods"
install_flatpak "com.github.tchx84.Flatseal" "Flatseal"
install_flatpak "hub.astralvixen.geforce-infinity" "GeForce Infinity"
install_flatpak "io.github.ilya_zlobintsev.LACT" "LACT (AMD GPU)"
install_flatpak "com.jetbrains.IntelliJ-IDEA-Community" "IntelliJ IDEA Community"
install_flatpak "io.dbeaver.DBeaverCommunity" "DBeaver Community"
install_flatpak "com.getpostman.Postman" "Postman"
install_flatpak "com.discordapp.Discord" "Discord"
install_flatpak "org.mozilla.Thunderbird" "Thunderbird"
install_flatpak "org.mozilla.firefox" "Firefox"

# 7. Hardware management (ASUS TUF automatic service)
echo "--> Configuring the Asusctl boot service..."
sudo tee /etc/systemd/system/asus-fan-apply.service > /dev/null <<'EOF'
[Unit]
Description=Apply Asusctl fan curve after boot
After=asusd.service graphical.target 

[Service]
Type=oneshot
ExecStartPre=/bin/sleep 30
ExecStart=/usr/bin/asusctl profile -P Balanced

[Install]
WantedBy=graphical.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable asus-fan-apply.service || true

# 8. Shell environment configuration
echo "--> Configuring aliases and environment helpers..."

ALIASES_FILE="$HOME/.bash_aliases"

cat > "$ALIASES_FILE" <<'EOF'
# Git aliases
alias gs="git status"
alias ga="git add ."
alias gc="git commit -m"
alias gp="git push"
alias gl="git log --oneline -10"
alias gd="git diff"
alias gb="git branch"
alias gco="git checkout"

# System aliases
alias ll="ls -lah"
alias la="ls -A"
alias l="ls -CF"
alias cls="clear"
alias update="sudo apt update && sudo apt upgrade -y"
alias install="sudo apt install"
alias remove="sudo apt remove"

# Development aliases
alias python="python3"
alias pip="pip3"
alias node-version="node --version && npm --version"

# Database aliases
alias psql-start="sudo systemctl start postgresql"
alias psql-stop="sudo systemctl stop postgresql"
alias psql-status="sudo systemctl status postgresql"
alias psql-restart="sudo systemctl restart postgresql"

# Docker aliases (if installed)
if command -v docker &> /dev/null; then
    alias dps="docker ps"
    alias di="docker images"
    alias dbuild="docker build"
    alias drun="docker run"
    alias dstop="docker stop"
fi

# Custom functions
mkproject() {
    local project_name=$1
    local project_type=${2:-general}
    mkdir -p ~/Projects/"$project_type"/"$project_name"
    cd ~/Projects/"$project_type"/"$project_name"
    echo "Project '$project_name' created in ~/Projects/$project_type/"
}

update-all() {
    echo "Updating APT..."
    sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
    echo "Updating Flatpak..."
    sudo flatpak update -y
    echo "✓ Everything is up to date!"
}
EOF

if ! grep -q "source.*bash_aliases" ~/.bashrc; then
    cat >> ~/.bashrc <<'EOF'

# Source aliases file if it exists
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
EOF
fi

source ~/.bashrc || true
echo "✓ Aliases configured in ~/.bash_aliases"

# 9. Development setup
echo "--> Creating the development directory structure..."
mkdir -p ~/Projects/{java,python,cpp,csharp,web,scripts,latex}
mkdir -p ~/.config/systemd/user
mkdir -p ~/.local/bin

# 10. Git setup
echo "--> Checking Git configuration..."
if ! git config --global user.name &> /dev/null; then
    echo "⚠ Configure your Git identity with:"
    echo "  git config --global user.name 'Your Name'"
    echo "  git config --global user.email 'your-email@example.com'"
else
    echo "✓ Git already configured for: $(git config --global user.name)"
fi

echo ""
echo "================================================================"
echo "Setup completed successfully!"
echo "================================================================"
echo ""
echo "Next steps:"
echo "1) Restart the computer to apply all changes:"
echo "   sudo reboot"
echo ""
echo "2) Verify the main tools:"
echo "   code --version       # VS Code"
echo "   git --version        # Git"
echo "   java -version        # Java 21"
echo "   psql --version       # PostgreSQL"
echo "   python3 --version    # Python 3"
echo "   node --version       # Node.js"
echo "   npm --version        # npm"
echo ""
echo "3) Configure SSH keys (if needed):"
echo "   ssh-keygen -t ed25519 -C 'your-email@example.com'"
echo ""
echo "4) Configure Git (if not already set):"
echo "   git config --global user.name 'Your Name'"
echo "   git config --global user.email 'your-email@example.com'"
echo ""
echo "5) Authenticate with GitHub:"
echo "   gh auth login"
echo ""
echo "6) Configure PostgreSQL (first time only):"
echo "   sudo -u postgres psql"
echo "   ALTER USER postgres PASSWORD 'new-password';"
echo "   \\q"
echo ""
echo "================================================================"