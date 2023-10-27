#!/bin/bash
# shellcheck disable=SC2148
# This file should be put in /etc/profile.d directory to initialise user environment

# Add anaconda to PATH
export PATH=/opt/anaconda/bin:$PATH

if [ ! -f ~/.condarc ]
then
  echo "Running conda init"
  /opt/anaconda/bin/conda init
  /opt/anaconda/bin/conda config --set auto_activate_base False
fi

if [ ! -f ~/.xsession ]
then
  echo "Setup xsession"
  echo xfce4-session >~/.xsession
fi

# Set VSCode extensions root directory
export VSCODE_EXTENSIONS=/opt/vscode/extensions

