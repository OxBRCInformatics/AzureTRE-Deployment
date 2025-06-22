#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

function Write-Log {
  echo  "$(date '+%Y-%m-%d %H:%M') init_vm.sh: $1"
}

Write-Log "START"

# Set environment variables for non-interactive installation
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

sudo apt-get update

# Install xrdp
Write-Log "Install xrdp"
sudo apt install -y xrdp
sudo usermod -a -G ssl-cert xrdp

# Make sure xrdp service starts up with the system
Write-Log "Enable xrdp"
sudo systemctl enable xrdp

# Install desktop environment if image doesn't have one already
Write-Log "Install XFCE"
sudo apt-get install -y xorg xfce4 xfce4-goodies dbus-x11 x11-xserver-utils gdebi-core xfce4-screensaver
echo xfce4-session > ~/.xsession

# Fix for blank screen on DSVM (/sh -> /bash due to conflict with profile.d scripts)
sudo sed -i 's|!/bin/sh|!/bin/bash|g' /etc/xrdp/startwm.sh

# Set the timezone to London
Write-Log "Set Timezone"
sudo timedatectl set-timezone Europe/London

# Fix Keyboard Layout
Write-Log "Set Keyboard Layout"
sudo sed -i 's/"us"/"gb"/' /etc/default/keyboard

## VS Code - Using official Microsoft recommended method
Write-Log "Install VS Code"
sudo apt-get install -y software-properties-common apt-transport-https wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt-get update
sudo apt-get install -y code

# Create VSCode system-wide extension directory and configure for silent operation
Write-Log "Configure VSCode for silent operation"
sudo mkdir -p /opt/vscode/extensions
sudo mkdir -p /opt/vscode/user-data
sudo chmod -R 755 /opt/vscode

# Create machine settings for VS Code to prevent first-run prompts
sudo mkdir -p /usr/share/code/resources/app/product.json.d
sudo tee /usr/share/code/resources/app/product.json.d/disable-telemetry.json > /dev/null <<EOF
{
  "telemetryOptedIn": false,
  "enableTelemetry": false,
  "enableCrashReporter": false
}
EOF

## Anaconda
Write-Log "Install Anaconda"
sudo apt-get install -y libgl1-mesa-glx libegl1-mesa libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6
wget -q https://repo.anaconda.com/archive/Anaconda3-2024.06-1-Linux-x86_64.sh -P /tmp
chmod +x /tmp/Anaconda3-2024.06-1-Linux-x86_64.sh
sudo bash /tmp/Anaconda3-2024.06-1-Linux-x86_64.sh -b -p /opt/anaconda

# Install anaconda-navigator silently
Write-Log "Install Anaconda Navigator"
/opt/anaconda/bin/conda install -y -c anaconda anaconda-navigator --quiet

## R
Write-Log "Install R"
wget -q https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc -O- | sudo tee /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
sudo add-apt-repository -y "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
sudo apt-get update
sudo apt-get install -y r-base

## RStudio Desktop
Write-Log "Install RStudio"
wget -q https://download1.rstudio.org/electron/jammy/amd64/rstudio-2024.12.1-563-amd64.deb -P /tmp
sudo gdebi --non-interactive /tmp/rstudio-2024.12.1-563-amd64.deb

## Azure CLI
Write-Log "Install Azure CLI"
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
sudo az extension add --name arcdata --system

## AzCopy
Write-Log "Install AzCopy"
wget -q https://aka.ms/downloadazcopy-v10-linux -P /tmp
tar -xzf /tmp/downloadazcopy-v10-linux -C /tmp
sudo cp /tmp/azcopy_linux_amd64_*/azcopy /usr/bin/
sudo chmod 755 /usr/bin/azcopy

## Google Chrome
Write-Log "Install Google Chrome"
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -P /tmp
sudo gdebi --non-interactive /tmp/google-chrome-stable_current_amd64.deb

## Docker CE
Write-Log "Install Docker CE"
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

## Azure Data Studio
Write-Log "Install Azure Data Studio"
ADS_FILENAME="/tmp/azuredatastudio-latest.deb"
ADS_URL="https://azuredatastudio-update.azurewebsites.net/latest/linux-deb-x64/stable"

# Download with better error handling
wget -q "$ADS_URL" -O "$ADS_FILENAME"

# Install prerequisites and ADS
sudo apt-get install -y libunwind8
sudo dpkg -i "$ADS_FILENAME" || sudo apt-get install -f -y

# Create ADS directories for extensions
Write-Log "Prepare ADS extension directories"
sudo mkdir -p /opt/azuredatastudio/user-data
sudo chmod -R 755 /opt/azuredatastudio

## Add ODBC drivers for SQL Server
Write-Log "Install ODBC Drivers"
# Use the same key we already imported for consistency
curl -fsSL https://packages.microsoft.com/config/ubuntu/"$(lsb_release -rs)"/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list > /dev/null
sudo apt-get update
sudo ACCEPT_EULA=Y apt-get install -y msodbcsql18 mssql-tools18 unixodbc-dev

## Grant access to Colord Policy file to avoid errors on RDP connections
Write-Log "Install Colord policy"
sudo cp -n /tmp/45-allow-colord.pkla /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla

## Install script to run at user login
Write-Log "Add User Login Script"
sudo cp /tmp/init_user_profile.sh /etc/profile.d/init_user_profile.sh
sudo chmod +x /etc/profile.d/init_user_profile.sh

## Final cleanup
Write-Log "Cleanup"
sudo apt-get autoremove -y
sudo apt-get autoclean
sudo rm -rf /var/cache/apt/archives/*
sudo rm -rf /tmp/*
rm -f /tmp/init_vm.sh /tmp/45-allow-colord.pkla

Write-Log "COMPLETED"
