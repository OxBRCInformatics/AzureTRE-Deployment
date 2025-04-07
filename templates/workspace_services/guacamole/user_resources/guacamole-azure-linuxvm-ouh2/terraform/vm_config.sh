#!/bin/bash

set -o errexit
set -o pipefail
# Uncomment for debugging (be cautious as it may expose secrets)
# set -o xtrace

echo "init_vm.sh: START"

# Ensure required services are started
echo "init_vm.sh: Enabling necessary services"
sudo systemctl enable xrdp
sudo systemctl start xrdp || true
sudo systemctl start docker || true

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

# Ensure storage is mounted if needed
if [ "${SHARED_STORAGE_ACCESS}" -eq 1 ]; then
  echo "init_vm.sh: Configuring shared storage"
  sudo apt-get install -y autofs

  # Define variables
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

  # Create required directories
  sudo mkdir -p "$mntPath" "$credentialRoot" "$mntRoot"

  # Create credential file if not exists
  if [ ! -f "$smbCredentialFile" ]; then
      echo "username=$storageAccountName" | sudo tee "$smbCredentialFile" > /dev/null
      echo "password=$storageAccountKey" | sudo tee -a "$smbCredentialFile" > /dev/null
      sudo chmod 600 "$smbCredentialFile"
  else
      echo "Credential file exists, skipping creation."
  fi

  # Configure autofs
  echo "$fileShareName -fstype=cifs,rw,file_mode=0777,dir_mode=0777,uid=1000,gid=1000,mfsymlinks,credentials=$smbCredentialFile :$smbPath" | sudo tee /etc/auto.fileshares > /dev/null
  echo "$mntRoot /etc/auto.fileshares --timeout=60" | sudo tee /etc/auto.master > /dev/null
  sudo systemctl restart autofs
  sudo ln -s "$mntPath" "/$fileShareName"
fi

# Ensure screen timeout and lock screen are disabled
echo "init_vm.sh: Disabling lock screen"
sudo apt-get remove -y xfce4-screensaver || true

# Create a polkit rule to allow color profile creation without authentication
sudo bash -c "cat >/etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla" <<EOF
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF

# Ensure RStudio is installed if not in the image
if ! command -v rstudio &> /dev/null; then
  echo "init_vm.sh: Installing RStudio"
  wget "${NEXUS_PROXY_URL}/repository/r-studio-download/electron/jammy/amd64/rstudio-2023.12.1-402-amd64.deb" -P /tmp
  sudo gdebi --non-interactive /tmp/rstudio-2023.12.1-402-amd64.deb
fi

# R config
sudo echo -e "local({\n    r <- getOption(\"repos\")\n    r[\"Nexus\"] <- \"""${NEXUS_PROXY_URL}/repository/r-proxy/\"\n    options(repos = r)\n}) \nSys.setenv(R_LIBCURL_SSL_REVOKE_BEST_EFFORT=TRUE)" | sudo tee /etc/R/Rprofile.site

# Ensure user session settings are configured
sudo -u "${VM_USER}" -i bash -c 'echo xfce4-session > ~/.xsession'
sudo -u "${VM_USER}" -i bash -c 'echo xset s off >> ~/.xsession'
sudo -u "${VM_USER}" -i bash -c 'echo xset -dpms >> ~/.xsession'
sudo -u "${VM_USER}" -i bash -c 'echo Xft.dpi: 192 >> ~/.Xresources'

# Jupiter Notebook Config
sudo sed -i -e 's/Terminal=true/Terminal=false/g' /usr/share/applications/jupyter-notebook.desktop

# Default Browser
sudo update-alternatives --config x-www-browser

# Docker install and config
sudo apt-get remove -y moby-tini || true
sudo apt-get install -y r-base-core
sudo apt-get install -y ca-certificates curl gnupg lsb-release
sudo apt-get install -y docker-compose-plugin docker-ce-cli containerd.io jq
sudo apt-get install -y docker-ce
jq -n --arg proxy "${NEXUS_PROXY_URL}:8083" '{"registry-mirrors": [$proxy]}' > /etc/docker/daemon.json
sudo usermod -aG docker "${VM_USER}"
sudo systemctl daemon-reload
sudo systemctl restart docker

echo "init_vm.sh: COMPLETE"
