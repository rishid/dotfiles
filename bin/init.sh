#!/bin/bash

# echo every command and exit if any command fails
set -ex

# update in case this is done on a brand new system that has not updated
sudo apt-get update

# install so additional apt repositories can be installed
sudo apt-get install --yes software-properties-common

# add ansible apt repository and install newest Ansible
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get install --yes ansible git

# clone repository if not already cloned
if [ -d ~/.dotfiles ]; then
  echo "$HOME/.dotfiles already cloned!"
else
  git clone https://github.com/rishid/dotfiles.git ~/.dotfiles
fi

