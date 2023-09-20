#!/bin/bash

# echo every command and exit if any command fails
set -ex

echo "Ask for sudo password"
sudo -v

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

# backup bashrc and bash_profile
if [ -f "$HOME/.bashrc" ] && [ ! -h "$HOME/.bashrc" ]
then
    echo "[i] Move current ~/.bashrc to ~/bashrc_backup"
    mv "$HOME/.bashrc" "$HOME/bashrc_backup"
fi

if [ -f "$HOME/.bash_profile" ] && [ ! -h "$HOME/.bash_profile" ]
then
    echo "[i] Move current ~/.bash_profile to ~/bash_profile_backup"
    mv "$HOME/.bash_profile" "$HOME/bash_profile_backup"
fi

echo "From now on you can use $ dotfiles to manage your dotfile"
echo "Done"
