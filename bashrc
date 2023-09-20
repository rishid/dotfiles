# ~/.bashrc
# Rishi Dhupar
# shamelessly stolen from http://github.com/axedcode/dotfiles/blob/master/.bashrc
 
# shell options
shopt -s cdable_vars
shopt -s cdspell
shopt -s checkwinsize
shopt -s cmdhist
shopt -s dotglob
shopt -s expand_aliases
#shopt -s extglob
shopt -s histappend
shopt -s hostcomplete
#shopt -s nocaseglob
stty -ctlecho

if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi
 
# history
export HISTSIZE="10000"
export HISTFILESIZE=${HISTSIZE}
export HISTCONTROL="ignoreboth"
 
# env vars
export PS1="[\[\033[36m\]\u\[\033[37m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]]$ "
export CDPATH=".:~/:~/dev"
export INPUTRC="/etc/inputrc"
export EDITOR="nano"
export PAGER="less"
export BROWSER="firefox"
export VISUAL="vim"
 
# colors for: console, ls, grep, less, man
eval `dircolors -b`
export GREP_COLOR="1;33"
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'
 
# start/attach screen session after logging in via ssh
if [ -n "$SSH_CONNECTION" ] && [ -z "$SCREEN_EXIST" ] && [ "$TERM" != "screen" ] ; then
  export SCREEN_EXIST=1
  screen -DR
fi
 
# aliases: program substitutions
alias vi="vim"
alias top="htop"
alias links="elinks"
 
# aliases: program defaults
alias ls="ls --color=auto -h1"
alias shred="shred -fuz"
alias nano="nano -AOSWx"
alias cp="cp -rpv"
alias mv="mv -v"
alias rm="rm -v"
alias mkdir="mkdir -pv"
alias df="df -h"
alias du="du -shc"
alias free="free -m"
alias grep="grep --color"
alias wget="wget -c"
alias lastlog="lastlog | grep -v Never"
alias reboot="sudo reboot"
alias shutdown="sudo shutdown -hP now"
alias iotop="iotop -o"
alias exit="clear; exit"
 
# aliases: navigation
alias ~="cd && clear"
alias home="~"
alias ..="cd .."
 
# aliases: network
alias home="sudo netcfg home"
 
# aliases: custom
alias bashrc="source ~/.bashrc"
alias reset="reset; bashrc"
alias webmirror="wget -m -k -p -np"
alias attach="tmux a"
 
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
 
# colorize pacman searches
pacsearch () 
{
  echo -e "$(pacman -Ss $@ | sed \
  -e 's#core/.*#\\033[1;31m&\\033[0;37m#g' \
  -e 's#extra/.*#\\033[0;32m&\\033[0;37m#g' \
  -e 's#community/.*#\\033[1;35m&\\033[0;37m#g' \
  -e 's#^.*/.* [0-9].*#\\033[0;36m&\\033[0;37m#g' )"
}
 
# extract different archives automatically
ex () {
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
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi }
 
# arch linux init script helpers
start() {
  for arg in $*; do
    sudo /etc/rc.d/$arg start
  done }
stop() {
  for arg in $*; do
    sudo /etc/rc.d/$arg stop
  done }
restart() {
  for arg in $*; do
    sudo /etc/rc.d/$arg restart
  done }
reload() {
  for arg in $*; do
    sudo /etc/rc.d/$arg reload
  done }