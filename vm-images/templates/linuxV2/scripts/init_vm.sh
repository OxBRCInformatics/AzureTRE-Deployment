#!/bin/bash
set -e

# Update package lists
sudo apt update

# Install a minimal desktop environment (Xfce)
sudo apt install -y xfce4 xfce4-terminal xrdp

# Enable and start XRDP for remote desktop access
sudo systemctl enable xrdp
sudo systemctl start xrdp

# Allow RDP through the firewall
sudo ufw allow 3389/tcp

# Set default session to Xfce for XRDP
echo "xfce4-session" > ~/.xsession

# Ensure proper permissions
sudo chmod 644 ~/.xsession

# Restart XRDP to apply changes
sudo systemctl restart xrdp

# Stop and disable XRDP to avoid stalling during image capture
sudo systemctl stop xrdp
sudo systemctl disable xrdp

# Clean up lingering processes that might stall deprovision
sudo pkill -u $(whoami) || true

# Clean up apt
sudo apt autoremove -y

# Deprovision the image for Azure capture
sudo waagent -deprovision+user -force

# Shutdown the VM to signal image is ready
sudo shutdown -h now

# Done
echo "Desktop environment setup complete and VM prepared for capture."
