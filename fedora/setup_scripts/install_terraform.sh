#!/usr/bin/env sh

TF_VERSION=1.1.2
echo "Installing terraform"
mkdir -p $HOME/bin
cd $HOME/bin

if [ ! -d "terraform" ]; then
	rm -rf terraform*
    wget https://releases.hashicorp.com/terraform/"$TF_VERSION"/terraform_"$TF_VERSION"_linux_amd64.zip
    unzip terraform_"$TF_VERSION"_linux_amd64.zip
    rm terraform*zip
fi
