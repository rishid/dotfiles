
Sets up and configures all of the software I use for development on an Ubuntu desktop - currently targets Ubuntu 12.04.

It also manages and maintains all my dotfiles

## What It Does
Each feature/language is grouped using Ansible roles, and can be found in the roles directory.

All the dotfiles that get linked into $HOME are grouped by language or feature where possible, and failing that lumped into the dotfiles role.

Roles look at the vars kept in group_vars for things like packages to install, and versions of certain runtime environments.


## Installation
### Fresh

1. Install git
 `sudo apt-get install git`
2. Clone the playbook
 `git clone https://github.com/rishid/dotfiles.git ~/.dotfiles`
3. Install ansible and any prereqs
 `~/.dotfiles/bin/init.sh`
4. Install the required Ansible roles
 `ansible-galaxy install -f -r ~/.dotfiles/requirements.yml`
5. Run it
 `~/.dotfiles/bin/dot-bootstrap`

### Update

Re-apply ansible to machine

`dot-update`

## Credits
https://github.com/sloria/dotfiles



git clone -n --config core.bare=true --separate-git-dir=$HOME/.dotgit git@github.com:gliech/dotfiles.git $(mktemp -d)
git --work-tree=$HOME --git-dir=$HOME/.dotgit reset HEAD
git --work-tree=$HOME --git-dir=$HOME/.dotgit checkout -b $HOSTNAME
git --work-tree=$HOME --git-dir=$HOME/.dotgit -c user.name="$USER" -c user.email="${USER}@${HOSTNAME}" commit -am "Backed up pre-existing configs to local branch"
git --work-tree=$HOME --git-dir=$HOME/.dotgit checkout master
