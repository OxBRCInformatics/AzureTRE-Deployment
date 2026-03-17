#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
# Uncomment this line to see each command for debugging (careful: this will show secrets!)
# set -o xtrace

# ---------------------------------------------------------------------------
# NOTE: The following are pre-configured in the VM image and are NOT repeated here:
#   - apt sources (Nexus proxied repositories)
#   - Base package installs (gnupg, wget, gdebi-core, etc.)
#   - Desktop environment (XFCE, xorg, dbus-x11)
#   - Azure Storage Explorer (installed at /opt/storage-explorer with desktop entry)
#   - pip (/etc/pip.conf)                    → Nexus PyPI proxy
#   - conda channels                         → Nexus conda proxy
#   - R repo (/etc/R/Rprofile.site)          → Nexus R proxy
#   - Docker daemon (/etc/docker/daemon.json) → Nexus registry mirror
#   - Chrome (replaces Edge)
#   - Jupyter (available via VS Code Jupyter extension)
#   - xfce4-screensaver disabled via XFCE settings
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Shared storage mount (per-workspace credentials, autofs/CIFS)
# ---------------------------------------------------------------------------
if [ "${SHARED_STORAGE_ACCESS}" -eq 1 ]; then
  sudo apt-get install -y autofs cifs-utils

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

  sudo mkdir -p "$mntPath"
  sudo mkdir -p "/etc/smbcredentials"
  sudo mkdir -p $mntRoot

  if [ ! -f "$smbCredentialFile" ]; then
      echo "username=$storageAccountName" | sudo tee "$smbCredentialFile" > /dev/null
      echo "password=$storageAccountKey" | sudo tee -a "$smbCredentialFile" > /dev/null
  else
      echo "The credential file $smbCredentialFile already exists, and was not modified."
  fi

  sudo chmod 600 "$smbCredentialFile"

  echo "$fileShareName -fstype=cifs,rw,file_mode=0777,dir_mode=0777,credentials=$smbCredentialFile :$smbPath" | sudo tee /etc/auto.fileshares > /dev/null
  echo "$mntRoot /etc/auto.fileshares --timeout=60" | sudo tee /etc/auto.master > /dev/null

  sudo systemctl restart autofs

  # Symlink for constant visible mount point
  sudo ln -s "$mntPath" "/$fileShareName"
fi

# ---------------------------------------------------------------------------
# Per-user xrdp / session setup
# ---------------------------------------------------------------------------
sudo -u "${VM_USER}" -i bash -c 'echo xfce4-session > ~/.xsession'
sudo -u "${VM_USER}" -i bash -c 'echo xset s off >> ~/.xsession'
sudo -u "${VM_USER}" -i bash -c 'echo xset -dpms >> ~/.xsession'

sudo systemctl enable xrdp
sudo service xrdp restart

# ---------------------------------------------------------------------------
# Docker — restart to ensure service is running
# daemon.json (Nexus registry mirror) is already written in the image
# ---------------------------------------------------------------------------
sudo systemctl restart docker
