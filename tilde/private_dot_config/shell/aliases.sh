#!/usr/bin/env sh
# @file Aliases
# @brief Houses the aliases that are included by `~/.bashrc` and `~/.zshrc`
# @description
#     This script is included by `~/.bashrc` and `~/.zshrc` to provide command aliases.

# Always use color output for `ls`
alias ls="ls --color=auto -h"
# List only directories
alias lsd="ls -lF | grep --color=never '^d'"
# List all files colorized in long format
alias ll="ls -lhF --color=auto"
# List all files colorized in long format, including dot files
alias lla="ls -lhaF --color=auto"

alias ln="ln -v"
alias shred="shred -fuvz"
#alias nano="nano -AOSWx"
alias cp="cp -rpv"
alias mv="mv -v"
alias rm="rm -v"
alias mkdir="mkdir -pv"
alias df="df -h"
alias du="du -hc"
alias free="free -m"
# Always enable colored `grep` output
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias wget="wget -c"
# alias exit="clear; exit"

# aliases: navigation
# alias ~="cd && clear"
alias home="~"
# alias -- -="cd -"
alias cd..="cd .."
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

# aliases: custom
alias e="$EDITOR"
alias h='history -i 1 | less +G'
alias bashrc="source ~/.bashrc"
# copy last downloaded file from ~/Downloads directory to current directory
alias lastDownload='cp ~/Downloads/`ls ~/Downloads -tr | tail -n 1` .'

# Pretty print the path
# alias path='printf "%b\n" "${PATH//:/\\n}"'

# Stopwatch
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'

# Lock screen.
alias afk="gnome-screensaver-command --lock"

# Shorter commands for the `Advanced Packaging Tool`
alias apti="sudo apt-get install"
alias aptr="sudo apt-get remove"
alias apts="sudo apt-cache search"
alias aptu="sudo apt-get update && sudo apt-get upgrade"

alias wget=wget --hsts-file="$XDG_CACHE_HOME/wget-hsts"
