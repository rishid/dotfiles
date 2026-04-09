#!/usr/bin/env sh

# This file is sourced by bash, zsh, AND fish.
# ONLY use plain `export VAR=value` — no if/then/fi, no eval, no subshells.
# Shell-specific logic belongs in profile.sh (bash/zsh) or conf.d/*.fish (fish).

export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

### Disable Telemetry
export DO_NOT_TRACK=1

### XDG Base Directories
# https://wiki.archlinux.org/index.php/XDG_Base_Directory
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

### Paths
export PATH="/opt/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/share/mise/shims:$PATH"

###
### General
###
export DOTFILES="$HOME/.dotfiles"

###
### Application Specific
###

### Ansible
export ANSIBLE_HOME="$XDG_DATA_HOME/ansible"

### bat
export BAT_CONFIG_PATH="$XDG_CONFIG_HOME/bat/config"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

### Cargo
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export PATH="$PATH:$CARGO_HOME/bin"

### Docker
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"

### HTTPie
export HTTPIE_CONFIG_DIR="$XDG_CONFIG_HOME/httpie"

### k9s
export K9SCONFIG="$XDG_CONFIG_HOME/k9s"

### Kube
export KUBECONFIG="$XDG_CONFIG_HOME/kube/config"

### Screen
export SCREENRC="$XDG_CONFIG_HOME/screen/screenrc"

### wget
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"

### History (bash/zsh — fish manages its own history separately)
export HISTCONTROL="ignoreboth"
export HISTSIZE=1000000000
export HISTFILESIZE="$HISTSIZE"
export HISTFILE="$XDG_STATE_HOME/bash/history"
export HIST_STAMPS="mm/dd/yyyy"
export HISTTIMEFORMAT="%F %T "
export HISTIGNORE="&:[bf]g:c:clear:history:exit:q:afk:pwd:* --help"
export SAVEHIST=50000
