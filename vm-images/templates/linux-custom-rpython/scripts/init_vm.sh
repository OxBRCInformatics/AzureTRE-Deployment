#!/bin/bash

set -o errexit
set -o pipefail
set -x  # Debug command tracing

function Write-Log {
  echo  "$(date '+%Y-%m-%d %H:%M') init_vm.sh: $1"
}

Write-Log "START"
sudo apt-get update
sudo apt-get install -y software-properties-common apt-transport-https wget curl gnupg lsb-release

Write-Log "Download files in parallel"
wget https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-x86_64.sh -P /tmp &
wget -q https://download1.rstudio.org/electron/jammy/amd64/rstudio-2024.12.1-563-amd64.deb -P /tmp &
wget https://aka.ms/downloadazcopy-v10-linux -P /tmp &
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -P /tmp &
wait

## VS Code
# Write-Log "Install VS Code"
# export DEBIAN_FRONTEND=noninteractive
# wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/vscode.gpg > /dev/null
# echo "deb [arch=amd64 signed-by=/usr/share/keyrings/vscode.gpg] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
# sudo apt-get update
# timeout 5m sudo apt-get install -y code || Write-Log "VS Code install failed or timed out"
# unset DEBIAN_FRONTEND

# Write-Log "Install VSCode extensions"
# sudo mkdir -p /opt/vscode/user-data /opt/vscode/extensions
# timeout 2m sudo code --extensions-dir="/opt/vscode/extensions" --user-data-dir="/opt/vscode/user-data" --install-extension janisdd.vscode-edit-csv || Write-Log "VSCode extension install failed"

## Anaconda
Write-Log "Configure Anaconda"
chmod +x /tmp/Anaconda3-2024.10-1-Linux-x86_64.sh
sudo bash /tmp/Anaconda3-2024.10-1-Linux-x86_64.sh -b -p /opt/anaconda
echo "export PATH=\"/opt/anaconda/bin:\$PATH\"" | sudo tee /etc/profile.d/anaconda.sh > /dev/null

## R
Write-Log "Install R"
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | gpg --dearmor | sudo tee /usr/share/keyrings/r-project.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/r-project.gpg] https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" | sudo tee /etc/apt/sources.list.d/r.list > /dev/null
sudo apt-get update
timeout 10m sudo apt-get install -y r-base || Write-Log "R install failed or timed out"

## RStudio Desktop
Write-Log "Install RStudio"
timeout 5m sudo dpkg -i /tmp/rstudio-2024.12.1-563-amd64.deb || sudo apt-get install -f -y

## Azure CLI
Write-Log "Install Azure CLI"
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash || Write-Log "Azure CLI install failed"
az extension add --name arcdata || Write-Log "Azure CLI extension 'arcdata' failed"

## AzCopy
Write-Log "Install AzCopy"
tar -xvf /tmp/downloadazcopy-v10-linux
sudo cp /tmp/azcopy_linux_amd64_*/azcopy /usr/bin/
sudo chmod 755 /usr/bin/azcopy

## Google Chrome
Write-Log "Install Google Chrome"
timeout 5m sudo dpkg -i /tmp/google-chrome-stable_current_amd64.deb || sudo apt-get install -f -y

## Docker CE
Write-Log "Install Docker CE"
sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
timeout 15m sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || Write-Log "Docker install failed"

## Azure Data Studio
Write-Log "Install Azure Data Studio"
ADS_FILENAME="/tmp/azuredatastudio-latest.deb"
ADS_URL="https://azuredatastudio-update.azurewebsites.net/latest/linux-deb-x64/stable/"
wget -qO "$ADS_FILENAME" "$ADS_URL"
sudo apt-get install -y libunwind8
timeout 5m sudo dpkg -i "$ADS_FILENAME" || sudo apt-get install -f -y
rm -f "$ADS_FILENAME"

## ODBC Drivers
Write-Log "Install ODBC Drivers"
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list" | sudo tee /etc/apt/sources.list.d/mssql-release.list > /dev/null
sudo apt-get update
timeout 5m sudo ACCEPT_EULA=Y apt-get install -y msodbcsql18 mssql-tools18 unixodbc-dev || Write-Log "ODBC driver install failed"

## Colord Policy
Write-Log "Install Colord policy"
sudo cp -n /tmp/45-allow-colord.pkla /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla

## User Login Script
Write-Log "Add User Login Script"
sudo cp /tmp/init_user_profile.sh /etc/profile.d/init_user_profile.sh

## Cleanup
Write-Log "Cleanup"
rm -f /tmp/init_vm.sh /tmp/45-allow-colord.pkla /tmp/Anaconda3-2024.06-1-Linux-x86_64.sh /tmp/google-chrome-stable_current_amd64.deb /tmp/downloadazcopy-v10-linux /tmp/rstudio-2024.12.1-563-amd64.deb
