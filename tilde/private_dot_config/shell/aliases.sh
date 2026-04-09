#!/usr/bin/env sh
# @file Aliases
# @brief Sourced by ~/.bashrc and ~/.zshrc (POSIX sh compatible, no bash-isms)

# ls — color flag differs between GNU coreutils (Linux) and BSD (macOS)
if [ "$(uname)" = "Darwin" ]; then
    alias ls="ls -Gh"
    alias ll="ls -lhFG"
    alias lla="ls -lhaFG"
else
    alias ls="ls --color=auto -h"
    alias ll="ls -lhF --color=auto"
    alias lla="ls -lhaF --color=auto"
fi
# List only directories
alias lsd="ls -lF | grep --color=never '^d'"

alias ln="ln -v"
alias shred="shred -fuvz"
alias cp="cp -rpv"
alias mv="mv -v"
alias rm="rm -v"
alias mkdir="mkdir -pv"
alias df="df -h"
alias du="du -hc"

# free doesn't exist on macOS
if command -v free >/dev/null 2>&1; then alias free="free -m"; fi

# Always enable colored grep output
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias wget="wget -c"

# Navigation
alias cd..="cd .."
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

# Custom
alias e="$EDITOR"
alias h='history -i 1 | less +G'
alias bashrc="source ~/.bashrc"
alias lastDownload='cp "$(ls -t ~/Downloads | head -n 1)" .'
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'

# Lock screen — different command on macOS vs Linux
if [ "$(uname)" = "Darwin" ]; then
    alias afk="pmset displaysleepnow"
else
    alias afk="gnome-screensaver-command --lock"
fi

# APT shortcuts — Debian/Ubuntu only
if command -v apt-get >/dev/null 2>&1; then
    alias apti="sudo apt-get install"
    alias aptr="sudo apt-get remove"
    alias apts="sudo apt-cache search"
    alias aptu="sudo apt-get update && sudo apt-get upgrade"
fi

alias wget='wget --hsts-file="$XDG_CACHE_HOME/wget-hsts"'
