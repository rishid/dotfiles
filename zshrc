# .zshrc -- Z shell configuration file
# Rishi D
# based off http://github.com/narfdotpl/dotfiles/blob/master/.zshrc

#--------
#  PATH
#--------

USER_PATH=~/bin

export PATH=$USER_PATH:$PATH

#------------
#  language
#------------
export LANG=en_US.UTF-8

#----------
#  editor
#----------
export EDITOR=emacs
export VISUAL=emacs

# `edit .zshrc`, `echo foo | edit`, `edit` == `edit .`
edit() {
    # check if stdin refers to terminal
    if [[ -t 0 ]]; then
        if [[ "$@" = "" ]]; then
            eval "$EDIT ."
        else
            eval "$EDIT $@"
        fi
    else
        eval "$EDIT -"
    fi
}

#--------------
#  completion
#--------------
autoload -U compinit && compinit

# make completion lists as compact as possible
setopt list_packed

# list by lines
setopt list_rows_fist

#-----------
#  history
#-----------

# log 10k commands
HISTSIZE=10000
SAVEHIST=$HISTSIZE
HISTFILE=~/.zsh_history

# append to HISTFILE when command is typed
setopt inc_append_history

# log timestamps
setopt extended_history

# if command is preceded with a space, don't log it
setopt hist_ignore_space

# if command duplicates any older one, don't show older ones
setopt hist_ignore_all_dups

# if command duplicates the *previous* one, don't log it
setopt hist_save_no_dups

#-------------
#  zsh magic
#-------------

autoload -U zmv

#----------
#  prompt
#----------
 
# subject PROMPT string to parameter expansion, command substitution,
# and arithmetic expansion
setopt prompt_subst

# set color names
DEFAULT=$'%{\e[0m%}'
RED=$'%{\e[0;31m%}'
GREEN=$'%{\e[0;32m%}'
BLUE=$'%{\e[0;34m%}'
WHITE=$'%{\e[0;37m%}'

# get git info for prompt
#
# full example: " ..master+&"
# (two dirs deep in repo, on branch master, dirty, with stashed changes)
git_prompt() {
    # check status and exit if there's no repo
    local status_dump="$(mktemp /tmp/git_prompt.XXXXXX)"
    trap "rm $status_dump" EXIT
    git status --porcelain > $status_dump 2> /dev/null
    [[ $? -gt 0 ]] && return

    # initial space
    echo -n ' '

    # depth
    git rev-parse --show-cdup | awk '{
        ORS = ""

        split($0, a, "/")
        depth = length(a) - 1
        while (depth --> 0)
            print "."
    }'

    # branch name
    git branch | sed -ne 's/* \(.*\)/\1/p' | tr -d '\n'

    # is dirty?
    [[ "$(head -c1 $status_dump)" != "" ]] && echo -n "+"

    # has stashed changes?
    [[ "$(git stash list | head -c1)" != "" ]] && echo -n "&"
}

# zsh has troubles displaying "⚡" with "PROMPT='%3~'", so...
short_pwd() {
    pwd | awk '{
        ORS = ""

        split($0, a, "/")
        a[3] = "~"

        len = length(a)
        start = len > 5 ? len - 2 : 3

        for (i = start; i <= len; i++) {
            print a[i]
            if (i != len)
                print "/"
        }
    }'
}

# show short path, git info and ">" sign
PROMPT='${BLUE}$(short_pwd)${GREEN}$(git_prompt) ${WHITE}>${DEFAULT} '

# show non-zero exit code
RPROMPT='${RED}%(0?..%?)${DEFAULT}'

#------------
#  bindings
#------------

# ctrl + a/e
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line

# up/down arrow: ipython-like history
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward

# alt + left/right: jump one word backward/forward
bindkey '^[^[[D' emacs-backward-word
bindkey '^[^[[C' emacs-forward-word

# forward delete
bindkey '^[[3~' delete-char

#-----------
#  aliases
#-----------

# change directory
alias .='cd ..'
alias ..='cd ../..'
alias ...='cd ../../..'

# clear the terminal screen
alias cl='clear'
 
# copy working directory path
alias cpwd='pwd | tr -d "\n" | pbcopy'

# go to Desktop
alias d='cd ~/Desktop'
 
# show date (example: 2009-11-07 01:16:21, Saturday)
alias da='date "+%Y-%m-%d %H:%M:%S, %A"'

# edit
alias e=$EDIT

# show shell history
alias h='history -i 1 | less +G'

alias l='ls -alhG'
alias lsd='ls -ld *(-/DN)'
alias pshell='phocoa shell'
alias top='top -u'
alias bigdirs='du -Sh ./ | grep -v "^-1" | grep "^[0-9]\\+M"'
alias base64urldecode='tr "\-_" "+/" | base64 -d | more'
alias vi=vim
alias vipager='vim -R -'
alias sgrep="grep --exclude '*.svn*' $*"
alias svnupdry='svn merge --dry-run -r BASE:HEAD .'
alias svnupdiff='svn diff -r BASE:HEAD .'

# Prompts: see http://aperiodic.net/phil/prompt/
setopt prompt_subst
autoload -U colors
colors

git_current_branch() {
    ref=$(git-symbolic-ref HEAD 2> /dev/null) || return
    echo " git@${ref#refs/heads/} "
}

function precmd { # runs before the prompt is rendered each time
    local exitstatus=$? 

    # show screen window # if available
    if [ $WINDOW ]; then
        PR_SCREEN="$WINDOW"
    fi

    [ $exitstatus -eq 0 ] && PR_LAST_EXIT="" || PR_LAST_EXIT=" %{$fg_bold[red]%}%?%{$reset_color%}"

    # put in here so length recalulation works well and prompts don't wrap
    PROMPT='[\
$PR_SCREEN\
$(git_current_branch)\
]:\
${PR_LAST_EXIT}\
> '
}
RPROMPT=" $USERNAME@%M:%~"     # prompt for right side of screen


# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete
zstyle ':completion:*' completions 1
zstyle ':completion:*' glob 1
zstyle :compinstall filename '~/.zshrc'
zstyle :compinstall filename '~/.stuff/zsh/rake-completion.zsh'

autoload -Uz compinit
if [ $USER = "root" ]; then
    # sudo'd shells run this zshrc; root was writing out zcompdump and thus breaking perms for the main user. have root skip dumping; the file should be there anyway.
    compinit -D
else
    compinit
fi
# End of lines added by compinstall

# override with local settings
source ~/.zshrc.local
