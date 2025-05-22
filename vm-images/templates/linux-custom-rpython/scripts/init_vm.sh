#!/bin/bash

set -o errexit
set -o pipefail

function Write-Log {
  echo  "$(date '+%Y-%m-%d %H:%M') init_vm.sh: $1"
}

Write-Log "START"
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
sudo apt-get install xorg xfce4 xfce4-goodies dbus-x11 x11-xserver-utils gdebi-core xfce4-screensaver --yes
echo xfce4-session > ~/.xsession

# Fix for blank screen on DSVM (/sh -> /bash due to conflict with profile.d scripts)
sudo sed -i 's|!/bin/sh|!/bin/bash|g' /etc/xrdp/startwm.sh

# Set the timezone to London
Write-Log "Set Timezone"
sudo timedatectl set-timezone Europe/London

# Fix Keyboard Layout
Write-Log "Set Keyboard Layout"
sudo sed -i 's/"us"/"gb"/' /etc/default/keyboard

# ## SMB Client
# Write-Log "Install SMB Client"
# sudo apt-get install smbclient -y

## VS Code
Write-Log "Install VS Code"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get install -y software-properties-common apt-transport-https wget
wget -O- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor | sudo tee /usr/share/keyrings/vscode.gpg
echo deb [arch=amd64 signed-by=/usr/share/keyrings/vscode.gpg] https://packages.microsoft.com/repos/vscode stable main | sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt-get update
sudo apt-get install -y code
unset DEBIAN_FRONTEND

## VSCode Extensions
Write-Log "Install VSCode extensions"
sudo mkdir /opt/vscode
sudo mkdir /opt/vscode/user-data
sudo mkdir /opt/vscode/extensions
sudo code --extensions-dir="/opt/vscode/extensions" --user-data-dir="/opt/vscode/user-data" --install-extension ms-python.python
sudo code --extensions-dir="/opt/vscode/extensions" --user-data-dir="/opt/vscode/user-data" --install-extension REditorSupport.r
sudo code --extensions-dir="/opt/vscode/extensions" --user-data-dir="/opt/vscode/user-data" --install-extension RDebugger.r-debugger
sudo code --extensions-dir="/opt/vscode/extensions" --user-data-dir="/opt/vscode/user-data" --install-extension ms-python.vscode-pylance
sudo code --extensions-dir="/opt/vscode/extensions" --user-data-dir="/opt/vscode/user-data" --install-extension ms-toolsai.vscode-ai-remote
# sudo code --extensions-dir="/opt/vscode/extensions" --user-data-dir="/opt/vscode/user-data" --install-extension ms-toolsai.vscode-ai
sudo code --extensions-dir="/opt/vscode/extensions" --user-data-dir="/opt/vscode/user-data" --install-extension ms-vscode-remote.remote-containers
sudo code --extensions-dir="/opt/vscode/extensions" --user-data-dir="/opt/vscode/user-data" --install-extension janisdd.vscode-edit-csv


# ## PyCharm Community
# Write-Log "Install PyCharm"
# sudo snap install pycharm-community --classic

# ## dbeaver
# Write-Log "Install Dbeaver"
# sudo snap install dbeaver-ce

# ## Azure Storage Explorer
# Write-Log "Install Storage Explorer"
# sudo apt install gnome-keyring -y
# sudo snap install storage-explorer
# sudo snap connect storage-explorer:password-manager-service :password-manager-service

## Anaconda
Write-Log "Install Anaconda"
sudo apt -y install libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6
wget https://repo.anaconda.com/archive/Anaconda3-2024.06-1-Linux-x86_64.sh -P /tmp
chmod +x /tmp/Anaconda3-2024.06-1-Linux-x86_64.sh
sudo bash /tmp/Anaconda3-2024.06-1-Linux-x86_64.sh -b -p /opt/anaconda
/opt/anaconda/bin/conda install -y -c anaconda anaconda-navigator

## R
Write-Log "Install R"
wget -q https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc -O- | sudo apt-key add -
sudo add-apt-repository -y "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
sudo apt update
sudo apt install -y r-base

## RStudio Desktop
Write-Log "Install RStudio"
wget -q https://download1.rstudio.org/electron/jammy/amd64/rstudio-2024.12.1-563-amd64.deb -P /tmp
sudo gdebi --non-interactive /tmp/rstudio-2024.12.1-563-amd64.deb



## Azure CLI
Write-Log "Install Azure CLI"
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az extension add --name arcdata

## AzCopy
Write-Log "Install AZCopy"
wget https://aka.ms/downloadazcopy-v10-linux -P /tmp
tar -xvf /tmp/downloadazcopy-v10-linux
sudo cp /tmp/azcopy_linux_amd64_*/azcopy /usr/bin/
sudo chmod 755 /usr/bin/azcopy

## Google Chrome
Write-Log "Install Google Chrome"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -P /tmp
sudo gdebi --non-interactive /tmp/google-chrome-stable_current_amd64.deb

## Docker CE
Write-Log "Install Docker CE"
sudo apt-get update &&  sudo apt-get install -y ca-certificates curl gnupg lsb-release
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

## Azure Data Studio
Write-Log "Install Azure Data Studio"
# Static filename for the latest download
ADS_FILENAME="azuredatastudio-latest.deb"
ADS_URL="https://azuredatastudio-update.azurewebsites.net/latest/linux-deb-x64/stable/"

# Download and rename the latest version
wget --content-disposition "$ADS_URL"
mv azuredatastudio-linux-*.deb "$ADS_FILENAME"

# Install prerequisites and ADS
sudo apt-get install -y libunwind8
sudo dpkg -i "$ADS_FILENAME" || sudo apt-get install -f -y

# Clean up
rm -f "$ADS_FILENAME"

## ADS Extensions
Write-Log "Install ADS extensions"
sudo mkdir /opt/azuredatastudio
sudo mkdir /opt/azuredatastudio/user-data
sudo azuredatastudio --extensions-dir /opt/vscode/extensions --user-data-dir /opt/azuredatastudio/user-data --install-extension microsoft.azcli
sudo azuredatastudio --extensions-dir /opt/vscode/extensions --user-data-dir /opt/azuredatastudio/user-data --install-extension microsoft.azuredatastudio-mysql
sudo azuredatastudio --extensions-dir /opt/vscode/extensions --user-data-dir /opt/azuredatastudio/user-data --install-extension microsoft.admin-pack
sudo azuredatastudio --extensions-dir /opt/vscode/extensions --user-data-dir /opt/azuredatastudio/user-data --install-extension microsoft.arc
sudo azuredatastudio --extensions-dir /opt/vscode/extensions --user-data-dir /opt/azuredatastudio/user-data --install-extension microsoft.machine-learning
sudo azuredatastudio --extensions-dir /opt/vscode/extensions --user-data-dir /opt/azuredatastudio/user-data --install-extension microsoft.azuredatastudio-postgresql

## Add ODBC drivers for SQL Server
Write-Log "Install ODBC Drivers"
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl -fsSL https://packages.microsoft.com/config/ubuntu/"$(lsb_release -rs)"/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list > /dev/null
sudo apt-get update
sudo ACCEPT_EULA=Y apt-get install -y msodbcsql18 mssql-tools18 unixodbc-dev

# ## Add psql client
# Write-Log "Install PSQL client"
# sudo apt-get update
# sudo apt-get install -y postgresql-client

## Grant access to Colord Policy file to avoid errors on RDP connections
Write-Log "Install Colord policy"
sudo cp -n /tmp/45-allow-colord.pkla /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla

## Install script to run at user login
Write-Log "Add User Login Script"
sudo cp /tmp/init_user_profile.sh /etc/profile.d/init_user_profile.sh

## Cleanup
Write-Log "Cleanup"
rm /tmp/init_vm.sh
rm /tmp/45-allow-colord.pkla
