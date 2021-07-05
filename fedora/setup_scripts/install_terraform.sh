#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root, use sudo "$0" instead" 1>&2
   exit 1
fi

SUDO_USER_HOME="$(eval echo "~$SUDO_USER")"
echo "Installing terraform"
mkdir -p $SUDO_USER_HOME/bin
cd $SUDO_USER_HOME/bin
wget https://releases.hashicorp.com/terraform/0.14.5/terraform_0.14.5_linux_amd64.zip
unzip terraform_0.14.5_linux_amd64.zip
rm terraform*zip
