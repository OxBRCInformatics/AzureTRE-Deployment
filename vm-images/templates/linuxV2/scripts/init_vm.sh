#!/bin/bash

set -o errexit
set -o pipefail
# set -o nounset
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

## R
echo "init_vm.sh: R Setup"
sudo apt install -y r-base

# RStudio Desktop
echo "init_vm.sh: RStudio"
wget https://download1.rstudio.org/electron/jammy/amd64/rstudio-2024.12.1-563-amd64.deb -P /tmp/2204
sudo gdebi --non-interactive /tmp/2204/rstudio-2024.12.1-563-amd64.deb


# Jupiter Notebook Config
sudo sed -i -e 's/Terminal=true/Terminal=false/g' /usr/share/applications/jupyter-notebook.desktop

## Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -P /tmp
sudo gdebi --non-interactive /tmp/google-chrome-stable_current_amd64.deb

## Cleanup
echo "init_vm.sh: Cleanup"
sudo apt -y autoremove
sudo apt install unattended-upgrades
