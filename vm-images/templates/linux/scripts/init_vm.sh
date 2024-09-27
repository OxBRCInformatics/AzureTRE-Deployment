#!/bin/bash

echo "init_vm.sh: START"
sudo apt update
sudo apt upgrade -y
sudo apt install -y gnupg2 software-properties-common apt-transport-https wget dirmngr gdebi-core

## Desktop
echo "init_vm.sh: Desktop"
sudo DEBIAN_FRONTEND=noninteractive
sudo apt install -y xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils


## xrdp
echo "init_vm.sh: xrdp"
sudo apt install -y xrdp xorgxrdp xfce4-session
sudo adduser xrdp ssl-cert
sudo systemctl enable xrdp


## Python 3.8 and Jupyter
# sudo apt install -y python3.8 python3.8-venv python3.8-dev jupyter-notebook


# Anaconda
echo "init_vm.sh: Anaconda"
sudo apt -y install libgl1-mesa-glx libegl1-mesa libxrandr2 libxrandr2 libxss1 libxcursor1 libxcomposite1 libasound2 libxi6 libxtst6
wget https://repo.anaconda.com/archive/Anaconda3-2022.05-Linux-x86_64.sh -P /tmp
chmod +x /tmp/Anaconda3-2022.05-Linux-x86_64.sh
bash /tmp/Anaconda3-2022.05-Linux-x86_64.sh -b -p /opt/anaconda
/opt/anaconda/bin/conda install -y -c anaconda anaconda-navigator


## JDK
sudo apt install -y openjdk-8-jdk


## ProM Tools
wget http://promtools.org/prom6/downloads/prom-6.12-all-platforms.tar.gz -P /tmp
sudo mkdir /opt/prom-tools
tar -xf /tmp/prom-6.12-all-platforms.tar.gz -C /opt/prom-tools
sudo chmod +x /opt/prom-tools/*.sh


# ## VS Code
# echo "init_vm.sh: Folders"
# sudo mkdir /opt/vscode/user-data
# sudo mkdir /opt/vscode/extensions

# echo "init_vm.sh: Keys"
# wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
# sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
# sudo apt update
# sudo apt install -y code gvfs-bin

## VSCode Extensions
echo "init_vm.sh: VSCode extensions"
code --extensions-dir="/opt/vscode/extensions" --user-data-dir="/opt/vscode/user-data" --install-extension ms-python.python
code --extensions-dir="/opt/vscode/extensions" --user-data-dir="/opt/vscode/user-data" --install-extension REditorSupport.r
code --extensions-dir="/opt/vscode/extensions" --user-data-dir="/opt/vscode/user-data" --install-extension RDebugger.r-debugger


## R
echo "init_vm.sh: R Setup"
wget -q https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc -O- | sudo apt-key add -
sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
sudo apt update
sudo apt install -y r-base


## RStudio Desktop
echo "init_vm.sh: RStudio"
wget https://download1.rstudio.org/desktop/bionic/amd64/rstudio-2022.07.2-576-amd64.deb -P /tmp
sudo gdebi --non-interactive /tmp/rstudio-2022.07.2-576-amd64.deb


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

sudo tee /usr/share/applications/storage-explorer.desktop <<END
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

# ## pgAdmin
# # Install the public key for the repository (if not done previously):
# curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg

# # Create the repository configuration file:
# sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update'

# # Install for desktop mode only:
# sudo apt install -y pgadmin4-desktop


## Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -P /tmp
sudo gdebi --non-interactive /tmp/google-chrome-stable_current_amd64.deb


## Add ouh_researcher group for directory permissions
echo "init_vm.sh: directory permissions"
getent group ouh_researcher || sudo groupadd ouh_researcher
sudo chgrp -R ouh_researcher /opt/anaconda
sudo chgrp -R ouh_researcher /opt/prom-tools
sudo chgrp -R ouh_researcher /opt/vscode/user-data
sudo chgrp -R ouh_researcher /opt/vscode/extensions

sudo chmod -R g+w /opt/anaconda
sudo chmod -R g+w /opt/prom-tools
sudo chmod -R g+w /opt/vscode/user-data
sudo chmod -R g+w /opt/vscode/extensions


## Add ouh_researcher as default extra group when creating new users
echo "init_vm.sh: Add OUH User Group"
sudo cp -f /tmp/adduser.conf /etc/adduser.conf


## Install script to run at user login
echo "init_vm.sh: User Login Script"
sudo cp -f /tmp/init_user_profile.sh /etc/profile.d/init_user_profile.sh


# ## Cleanup
echo "init_vm.sh: Cleanup"
sudo rm -R /tmp/init_vm.sh
sudo rm -R /tmp/init_user_profile.sh
sudo rm -R /tmp/adduser.conf
sudo rm -R /tmp/Anaconda3-2022.05-Linux-x86_64.sh
sudo rm -R /tmp/rstudio-2022.07.2-576-amd64.deb
sudo rm -R /tmp/google-chrome-stable_current_amd64.deb
sudo apt -y autoremove
sudo apt install unattended-upgrades
