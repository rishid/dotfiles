#!/usr/bin/env sh

# This file is meant to compatible with multiple shells, including:
# bash, zsh, and fish. For this reason, use this syntax:
#    export VARNAME=value

export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

### Disable Telemetry
export DO_NOT_TRACK=1

### XDG
# Source: # https://wiki.archlinux.org/index.php/XDG_Base_Directory
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

### Paths
export PATH="/opt/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib"

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
# export MACHINE_STORAGE_PATH="$XDG_DATA_HOME/docker-machine"

### Go
# export GOPATH="$XDG_DATA_HOME/go"
# export GO111MODULE=on
# export PATH="$PATH:${GOPATH}/bin"
# if command -v go > /dev/null && which go | grep -q 'asdf' > /dev/null && command -v asdf > /dev/null; then
#   GOROOT="$(asdf where golang)/go"
#   export GOROOT
#   export PATH="$PATH:${GOROOT}/bin"
# elif command -v go > /dev/null && command -v brew > /dev/null; then
#   GOROOT="$(brew --prefix go)/libexec"
#   export GOROOT
#   export PATH="$PATH:${GOROOT}/bin"
# fi

### HTTPie
export HTTPIE_CONFIG_DIR="$XDG_CONFIG_HOME/httpie"

### k9s
export K9SCONFIG="$XDG_CONFIG_HOME/k9s"

### Kube
export KUBECONFIG="$XDG_CONFIG_HOME/kube/config"

### Screen
export SCREENRC="$XDG_CONFIG_HOME"/screen/screenrc

### wget
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"

### History
# TODO: move to bash specific file
export HISTCONTROL="ignoreboth"
export HISTSIZE=1000000000
export HISTFILESIZE="$HISTSIZE"
export HISTFILE="$XDG_STATE_HOME"/bash/history
export HIST_STAMPS="mm/dd/yyyy"
export HISTTIMEFORMAT="%F %T "
export HISTIGNORE="&:[bf]g:c:clear:history:exit:q:afk:pwd:* --help"
export SAVEHIST=50000

# NixOS
export NIX_LD_LIBRARY_PATH=/run/current-system/sw/share/nix-ld/lib
export NIX_LD=/run/current-system/sw/share/nix-ld/lib/ld.so

### Man pages
# TODO: move to bash specific file
# export LESS_TERMCAP_mb=$'\e[1;32m'
# export LESS_TERMCAP_md=$'\e[1;32m'
# export LESS_TERMCAP_me=$'\e[0m'
# export LESS_TERMCAP_se=$'\e[0m'
# export LESS_TERMCAP_so=$'\e[01;33m'
# export LESS_TERMCAP_ue=$'\e[0m'
# export LESS_TERMCAP_us=$'\e[1;4;31m'
# export LESSHISTFILE=-
# export MANPAGER="less -X"
