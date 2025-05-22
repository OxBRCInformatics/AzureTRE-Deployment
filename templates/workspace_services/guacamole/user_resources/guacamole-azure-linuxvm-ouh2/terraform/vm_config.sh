#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
# Uncomment this line to see each command for debugging (careful: this will show secrets!)
set -o xtrace

# Remove apt sources not included in sources.list file
sudo rm -f /etc/apt/sources.list.d/*

# Update apt packages from configured Nexus sources
echo "init_vm.sh: START"
sudo apt update || true
sudo apt upgrade -y
sudo apt install -y gnupg2 software-properties-common apt-transport-https wget dirmngr gdebi-core debconf-utils
sudo apt-get update || true

## Desktop
echo "init_vm.sh: Desktop"
sudo systemctl start gdm3 || true
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true dpkg-reconfigure gdm3 || true
sudo apt install -y xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils
echo /usr/sbin/gdm3 > /etc/X11/default-display-manager

## Python 3.8 and Jupyter
sudo apt install -y jupyter-notebook microsoft-edge-dev

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


# Make sure xrdp service starts up with the system
# sudo systemctl enable xrdp

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
  sudo mkdir -p "/etc/smbcredentials"
  sudo mkdir -p $mntRoot

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

  # Configure autofs
  echo "$fileShareName -fstype=cifs,rw,file_mode=0777,dir_mode=0777,credentials=$smbCredentialFile :$smbPath" | sudo tee /etc/auto.fileshares > /dev/null
  echo "$mntRoot /etc/auto.fileshares --timeout=60" | sudo tee /etc/auto.master > /dev/null

  # Restart service to register changes
  sudo systemctl restart autofs

  # Autofs mounts when accessed for 60 seconds.  Folder created for constant visible mount
  sudo ln -s "$mntPath" "/$fileShareName"
fi

# R config
if [ "${R_CONFIG}" == "true" ]; then
  sudo echo -e "local({\n    r <- getOption(\"repos\")\n    r[\"Nexus\"] <- \"""${NEXUS_PROXY_URL}/repository/r-proxy/\"\n    options(repos = r)\n})" | sudo tee /etc/R/Rprofile.site
fi

### Anaconda Config
if [ "${CONDA_CONFIG}" == "true" ]; then
  export PATH="/opt/anaconda/condabin":$PATH
  export PATH="/opt/anaconda/bin":$PATH
  export PATH="/opt/anaconda/envs/py38_default/bin":$PATH
  conda config
  conda config --add channels "${NEXUS_PROXY_URL}"/repository/conda-mirror/main/  --system
  conda config --add channels "${NEXUS_PROXY_URL}"/repository/conda-repo/main/  --system
  conda config --remove channels defaults --system
  conda config --set channel_alias "${NEXUS_PROXY_URL}"/repository/conda-mirror/  --system
fi

# Docker config
if [ "${DOCKER_CONFIG}" == "true" ]; then
  # Create Docker config directory if it doesn't exist
  sudo mkdir -p /etc/docker/
  # Configure Docker registry mirrors
  jq -n --arg proxy "${NEXUS_PROXY_URL}:8083" '{"registry-mirrors": [$proxy]}' | sudo tee /etc/docker/daemon.json > /dev/null
  # Restart Docker service to apply configuration
  sudo systemctl restart docker
fi

## Prevent screen timeout and lock screen
echo "init_vm.sh: Disabling lock screen"
# Remove xfce4-screensaver (to disable screen saver)
sudo apt-get remove xfce4-screensaver -y

## Install xrdp so Guacamole can connect via RDP
echo "init_vm.sh: xrdp"
sudo apt install -y xrdp xorgxrdp xfce4-session
sudo adduser xrdp ssl-cert
sudo -u "${VM_USER}" -i bash -c 'echo xfce4-session > ~/.xsession'
sudo -u "${VM_USER}" -i bash -c 'echo xset s off >> ~/.xsession'
sudo -u "${VM_USER}" -i bash -c 'echo xset -dpms >> ~/.xsession'

# Fix for blank screen on DSVM (/sh -> /bash due to conflict with profile.d scripts)
sudo sed -i 's|!/bin/sh|!/bin/bash|g' /etc/xrdp/startwm.sh

# Make sure xrdp service starts up with the system
sudo systemctl enable xrdp
sudo service xrdp restart

## Cleanup
echo "init_vm.sh: Cleanup"
