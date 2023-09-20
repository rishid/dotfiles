# .zshrc -- Z shell configuration file
# Rishi Dhupar
# based off http://github.com/narfdotpl/dotfiles/blob/master/.zshrc

#--------
#  PATH
#--------

USER_PATH=~/bin
PORT_PATH=/opt/local/bin:/opt/local/sbin
POSTGRES_PATH=/Library/PostgreSQL/8.3/bin/
PYTHON_PATH=/Library/Frameworks/Python.framework/Versions/2.6/bin
RUBY_PATH=~/.gem/ruby/1.8/bin

export PATH=$USER_PATH:$PORT_PATH:$POSTGRES_PATH:$PYTHON_PATH:$RUBY_PATH:$PATH

#------------
#  language
#------------

export LANG=en_US.UTF-8

#----------
#  editor
#----------

export EDITOR=emacs
export VISUAL=emacs


#--------------
#  completion
#--------------

autoload -U compinit
compinit

# make completion lists as compact as possible
setopt list_packed


#-----------
#  history
#-----------

# log 10k commands
HISTSIZE=10000
SAVEHIST=$HISTSIZE
HISTFILE=~/.history

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

#--------
#  MOTD
#--------


# aliases
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
