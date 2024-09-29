#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
# Uncomment this line to see each command for debugging (careful: this will show secrets!)
# set -o xtrace

# Remove apt sources not included in sources.list file
sudo rm -f /etc/apt/sources.list.d/*


# Update apt packages from configured Nexus sources
echo "init_vm.sh: START"
sudo apt update || true
sudo apt upgrade -y
sudo apt install -y gnupg2 software-properties-common apt-transport-https wget dirmngr gdebi-core
sudo apt-get update || true

## Desktop
echo "init_vm.sh: Desktop"
sudo systemctl start gdm3 || true
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true dpkg-reconfigure gdm3 || true
sudo apt install -y xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils
echo /usr/sbin/gdm3 > /etc/X11/default-display-manager

## Install xrdp so Guacamole can connect via RDP
echo "init_vm.sh: xrdp"
sudo apt install -y xrdp xorgxrdp xfce4-session
sudo adduser xrdp ssl-cert
sudo -u "${VM_USER}" -i bash -c 'echo xfce4-session > ~/.xsession'
sudo -u "${VM_USER}" -i bash -c 'echo xset s off >> ~/.xsession'
sudo -u "${VM_USER}" -i bash -c 'echo xset -dpms >> ~/.xsession'

# Make sure xrdp service starts up with the system
sudo systemctl enable xrdp
sudo service xrdp restart

# Disable colord service if color management is not required
sudo systemctl disable colord
sudo systemctl stop colord

## Python 3.8 and Jupyter
sudo apt install -y jupyter-notebook microsoft-edge-dev

## VS Code
echo "init_vm.sh: VS Code"
sudo apt install -y code
sudo apt install -y gvfs-bin || true

echo "init_vm.sh: Folders"
sudo mkdir -p /opt/vscode/user-data
sudo mkdir -p /opt/vscode/extensions

# Install Azure CLI
echo "init_vm.sh: Installing Azure CLI"
sudo apt install azure-cli -y

## VSCode Extensions
echo "init_vm.sh: VSCode extensions"
sudo code --extensions-dir="/opt/vscode/extensions" --user-data-dir="/opt/vscode/user-data" --install-extension ms-python.python
sudo code --extensions-dir="/opt/vscode/extensions" --user-data-dir="/opt/vscode/user-data" --install-extension REditorSupport.r
sudo code --extensions-dir="/opt/vscode/extensions" --user-data-dir="/opt/vscode/user-data" --install-extension RDebugger.r-debugger

# Additional VS Code Extensions
sudo code --extensions-dir="/opt/vscode/extensions" --user-data-dir="/opt/vscode/user-data" --install-extension njpwerner.autodocstring         # AutoDocstring - Python Docstring Generator
sudo code --extensions-dir="/opt/vscode/extensions" --user-data-dir="/opt/vscode/user-data" --install-extension ms-python.data-wrangler      # Data Wrangler (Microsoft)
sudo code --extensions-dir="/opt/vscode/extensions" --user-data-dir="/opt/vscode/user-data" --install-extension GrapeCity.gc-excelviewer      # Excel Viewer (Grape City)
sudo code --extensions-dir="/opt/vscode/extensions" --user-data-dir="/opt/vscode/user-data" --install-extension formulahendry.auto-complete     # Path Autocomplete (Mihai Vilcu)
sudo code --extensions-dir="/opt/vscode/extensions" --user-data-dir="/opt/vscode/user-data" --install-extension KevinRose.vsc-python-indent      # Python Indent (Kevin Rose)
sudo code --extensions-dir="/opt/vscode/extensions" --user-data-dir="/opt/vscode/user-data" --install-extension Gruntfuggly.todo-tree          # Todo Tree (Gruntfuggly)


# Azure Storage Explorer
sudo apt-get remove -y dotnet-host-7.0
sudo apt-get remove -y dotnet-sdk-7.0
sudo apt-get install -y dotnet-sdk-8.0
sudo apt install gnome-keyring -y

sudo chmod 666 /etc/profile

echo "export DOTNET_ROOT=/usr/share/dotnet
export PATH=$PATH:/usr/share/dotnet
" | sudo tee -a /etc/profile

sudo chmod 644 /etc/profile

wget -q "${NEXUS_PROXY_URL}"/repository/microsoft-download/A/E/3/AE32C485-B62B-4437-92F7-8B6B2C48CB40/StorageExplorer-linux-x64.tar.gz -P /tmp
sudo mkdir /opt/storage-explorer
sudo tar xvf /tmp/StorageExplorer-linux-x64.tar.gz -C /opt/storage-explorer
sudo chmod +x /opt/storage-explorer/*

sudo tee /usr/share/applications/storage-explorer.desktop << END
[Desktop Entry]
Name=Storage Explorer
Comment=Azure Storage Explorer
Exec=/opt/storage-explorer/StorageExplorer
Icon=/opt/storage-explorer/resources/app/out/app/icon.png
Terminal=false
Type=Application
StartupNotify=false
StartupWMClass=Code
Categories=Development;
END

## R
echo "init_vm.sh: R Setup"
wget -q https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc -O- | sudo apt-key add -
sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
sudo apt update
sudo apt install -y r-base

# RStudio Desktop
echo "init_vm.sh: RStudio"
wget "${NEXUS_PROXY_URL}"/repository/r-studio-download/electron/jammy/amd64/rstudio-2023.12.1-402-amd64.deb -P /tmp/2204
wget "${NEXUS_PROXY_URL}"/repository/r-studio-download/electron/focal/amd64/rstudio-2023.12.1-402-amd64.deb -P /tmp/2004
sudo gdebi --non-interactive /tmp/"${APT_SKU}"/rstudio-2023.12.1-402-amd64.deb

# Fix for blank screen on DSVM (/sh -> /bash due to conflict with profile.d scripts)
sudo sed -i 's|!/bin/sh|!/bin/bash|g' /etc/xrdp/startwm.sh

if [ "${SHARED_STORAGE_ACCESS}" -eq 1 ]; then
  # Install required packages
  sudo apt-get install autofs -y

  # Pass in required variables
  storageAccountName="${STORAGE_ACCOUNT_NAME}"
  storageAccountKey="${STORAGE_ACCOUNT_KEY}"
  httpEndpoint="${HTTP_ENDPOINT}"
  fileShareName="${FILESHARE_NAME}"
  mntRoot="/fileshares"
  credentialRoot="/etc/smbcredentials"

  mntPath="$mntRoot/$fileShareName"
  # shellcheck disable=SC2308
  smbPath=$(echo "$httpEndpoint" | cut -c7-"$(expr length "$httpEndpoint")")$fileShareName
  smbCredentialFile="$credentialRoot/$storageAccountName.cred"

  # Create required file paths
  sudo mkdir -p "$mntPath"
  sudo mkdir -p "$credentialRoot"
  sudo mkdir -p "$mntRoot"

  ### Auto FS to persist storage
  # Create credential file
  if [ ! -f "$smbCredentialFile" ]; then
      echo "username=$storageAccountName" | sudo tee "$smbCredentialFile" > /dev/null
      echo "password=$storageAccountKey" | sudo tee -a "$smbCredentialFile" > /dev/null
  else
      echo "The credential file $smbCredentialFile already exists, and was not modified."
  fi

  # Change permissions on the credential file so only root can read or modify the password file.
  sudo chmod 600 "$smbCredentialFile"

  # Configure autofs with adjusted options
  echo "$fileShareName -fstype=cifs,rw,uid=$(id -u),gid=$(id -g),file_mode=0777,dir_mode=0777,credentials=$smbCredentialFile ://$smbPath" | sudo tee /etc/auto.fileshares > /dev/null
  echo "$mntRoot /etc/auto.fileshares --timeout=60" | sudo tee /etc/auto.master > /dev/null

  # Restart service to register changes
  sudo systemctl restart autofs

  # Create a visible link to the shared directory
  sudo ln -s "$mntPath" "/$fileShareName"

  # Ensure permissions are set correctly on the mount point
  sudo chmod 777 "$mntPath"
fi

# Install LibreOffice
echo "init_vm.sh: Installing LibreOffice"
sudo apt install -y libreoffice

# Anaconda
echo "init_vm.sh: Anaconda"
sudo apt -y install libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6
wget https://repo.anaconda.com/archive/Anaconda3-2022.05-Linux-x86_64.sh -P /tmp
chmod +x /tmp/Anaconda3-2022.05-Linux-x86_64.sh
bash /tmp/Anaconda3-2022.05-Linux-x86_64.sh -b -p /opt/anaconda
/opt/anaconda/bin/conda install -y -c anaconda anaconda-navigator

### Anaconda Config
if [ "${CONDA_CONFIG}" -eq 1 ]; then
  echo "init_vm.sh: Anaconda"
  export PATH="/opt/condabin":$PATH
  export PATH="/opt/bin":$PATH
  export PATH="/opt/envs/py38_default/bin":$PATH
  conda config --add channels "${NEXUS_PROXY_URL}"/repository/conda-mirror/main/  --system
  conda config --add channels "${NEXUS_PROXY_URL}"/repository/conda-repo/main/  --system
  conda config --remove channels defaults --system
  conda config --set channel_alias "${NEXUS_PROXY_URL}"/repository/conda-mirror/  --system
fi

## JDK
sudo apt install -y openjdk-8-jdk

## ProM Tools
wget http://promtools.org/prom6/downloads/prom-6.12-all-platforms.tar.gz -P /tmp
sudo mkdir /opt/prom-tools
tar -xf /tmp/prom-6.12-all-platforms.tar.gz -C /opt/prom-tools
sudo chmod +x /opt/prom-tools/*.sh

## PostgreSQL
# Create the file repository configuration:
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Import the repository signing key:
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Update the package lists:
sudo apt-get update

# Install the latest version of PostgreSQL.
# If you want a specific version, use 'postgresql-12' or similar instead of 'postgresql':
sudo apt-get -y install postgresql

# Docker install and config
sudo apt-get remove -y moby-tini || true
sudo apt-get install -y r-base-core
sudo apt-get install -y ca-certificates curl gnupg lsb-release
sudo apt-get install -y docker-compose-plugin docker-ce-cli containerd.io jq
sudo apt-get install -y docker-ce
jq -n --arg proxy "${NEXUS_PROXY_URL}:8083" '{"registry-mirrors": [$proxy]}' > /etc/docker/daemon.json
sudo systemctl daemon-reload
sudo systemctl restart docker

# R config
sudo echo -e "local({\n    r <- getOption(\"repos\")\n    r[\"Nexus\"] <- \"""${NEXUS_PROXY_URL}\"/repository/r-proxy/\"\n    options(repos = r)\n})" | sudo tee /etc/R/Rprofile.site

# Jupiter Notebook Config
sudo sed -i -e 's/Terminal=true/Terminal=false/g' /usr/share/applications/jupyter-notebook.desktop

# Default Browser
sudo update-alternatives --config x-www-browser

# Prevent screen timeout
echo "init_vm.sh: Preventing Timeout"
sudo apt-get remove xfce4-screensaver -y
sudo apt-get remove -y light-locker

xfconf-query -c xfce4-screensaver -p /active -s false
xfconf-query -c xfce4-session -p /LockScreen -s false
xfconf-query -c xfce4-session -p /Session/Idle -s 0


## Cleanup
echo "init_vm.sh: Cleanup"
sudo shutdown -r now
