#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root, use sudo "$0" instead" 1>&2
   exit 1
fi

TF_VERSION=0.14.5
SUDO_USER_HOME="$(eval echo "~$SUDO_USER")"
echo "Installing terraform"
mkdir -p $SUDO_USER_HOME/bin
cd $SUDO_USER_HOME/bin

if [ ! -d "terraform" ]; then
    wget https://releases.hashicorp.com/terraform/$TF_VERSION/terraform_$TF_VERSION_linux_amd64.zip
    unzip terraform_$TF_VERSION_linux_amd64.zip
    rm terraform*zip
fi
