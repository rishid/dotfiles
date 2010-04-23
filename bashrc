# ~/.bashrc
# Rishi Dhupar
# sources of this chaos:
# http://github.com/axedcode/dotfiles/blob/master/.bashrc

#-----------
# PATH
#-----------
USER_PATH=~/bin
export PATH=$USER_PATH:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

#-----------
# completion
#-----------
# Make sure bash-completion is activated
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

#-----------
#  history
#-----------
export HISTSIZE=100000
export HISTFILESIZE=$HISTSIZE
export HISTFILE=~/.bash_history
export HISTIGNORE="cd:ls:[bf]g"

# append to HISTFILE when command is typed
shopt -s histappend
shopt -s cmdhist
export HISTCONTROL="ignoreboth"
export HISTTIMEFORMAT="%F %T "

#--------
#  MOTD
#--------
# example: stallman (Linux), up 29 days
#python ~/.scripts/show_machine_info.py

#-------
# prompt
#-------
export PS1="[\[\033[36m\]\u\[\033[37m\]@\[\033[32m\]\h:\[\033[34;1m\]\w\[\033[m\]]$ "

# shell options
shopt -s cdable_vars
shopt -s cdspell
shopt -s checkwinsize
shopt -s dotglob
shopt -s expand_aliases
stty -ctlecho

# env vars
#export CDPATH=".:~/:~/dev"
export INPUTRC="/etc/inputrc"
export EDITOR="emacs"
export PAGER="less"
export BROWSER="firefox"
export VISUAL="emacs"
export LANG=en_US.UTF-8
 
# colors for: console, ls, grep, less, man
eval `dircolors -b`
# display grep matches in a color
export GREP_COLOR="1;33"
# For colorful man pages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'
 
# start/attach screen session after logging in via ssh
#if [ -n "$SSH_CONNECTION" ] && [ -z "$SCREEN_EXIST" ] && [ "$TERM" != "screen" ] ; then
#  export SCREEN_EXIST=1
#  screen -DR
#fi
 
#-----------
#  aliases
#-----------
alias ls="ls --color=auto -h"
alias lsd="ls -ld *(-/DN)"
alias ll="ls -lh --color=auto"
alias shred="shred -fuz"
#alias nano="nano -AOSWx"
alias cp="cp -rpv"
alias mv="mv -v"
alias rm="rm -v"
alias mkdir="mkdir -pv"
alias df="df -h"
alias du="du -hc"
alias free="free -m"
alias grep="grep --color"
alias wget="wget -c"
alias exit="clear; exit"
 
# aliases: navigation
alias ~="cd && clear"
alias home="~"
alias ..='cd ..'
alias ...='..;..'

# aliases: custom
alias e=$EDIT
alias h='history -i 1 | less +G'
alias bashrc="source ~/.bashrc"

if [ -f ~/.bashrc.local ]; then
    . ~/.bashrc.local
fi 
 
# make a directory then cd into it
function mkcd() { mkdir "$1" && cd "$1"; }
 
# recursively set ownership
function mkmine() { sudo chown -R ${USER} ${1:-.}; }
 
# simple calculator
function calc() { echo "$*" | bc; }
 
# make a tar.gz
function mktar() { tar cvzpf "${1%%/}.tar.gz" "${1%%/}/"; }
# sort a directory's used space and displays total gigabytes
dusort() { sudo \du -x -B 1048576 $1 | sort -rn | head -n10; }
 
# extract different archives automatically
extract () {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xvjf $1   ;;
      *.tar.gz)    tar xvzf $1   ;;
      *.bz2)       bunzip2 $1    ;;
      *.gz)        gunzip $1     ;;
      *.tar)       tar xf $1     ;;
      *.tbz2)      tar xjf $1    ;;
      *.tgz)       tar xzf $1    ;;
      *.zip)       unzip $1      ;;
      *.Z)         uncompress $1 ;;
      *.rar)       7z x $1       ;;
      *.7z)        7z x $1       ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi }
 