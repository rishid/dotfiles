#!/usr/bin/env sh
# @file Shared Profile
# @brief Main shell profile that is used to combine the shared profile configurations that are used by both the `~/.bashrc` and `~/.zshrc` files
# @description
#     This script is included by `~/.bashrc` and `~/.zshrc` to include imports and settings that are common to both the Bash
#     and ZSH shells.

# Avoid PATH duplication inside Tmux sessions.
# if [ -n "$TMUX" ] && [ -f /etc/profile ]; then
# 	# shellcheck disable=SC2123
# 	PATH=""
# 	source /etc/profile
# fi

# XDG dirs
# source "$HOME/.config/shell/exports.sh"

# Aliases / Functions / Exports
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
[ ! -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/exports.sh" ] || . "${XDG_CONFIG_HOME:-$HOME/.config}/shell/exports.sh"
[ ! -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliases.sh" ] || . "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliases.sh"
[ ! -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/functions.sh" ] || . "${XDG_CONFIG_HOME:-$HOME/.config}/shell/functions.sh"

# if running bash
# if [ -n "$BASH_VERSION" ]; then
#   # include .bashrc if it exists
#   if [ -f "$HOME/.bashrc" ]; then
#     . "$HOME/.bashrc"
#   fi
# fi

# if hash keychain 2>/dev/null; then
# 	eval "$(keychain --dir "$XDG_CACHE_HOME/keychain" --eval --agents ssh -Q --quiet current)"
# fi

# Tmux: on login, attach to existing session or create a new one.
# if [[ $- == *i* ]] && hash tmux 2>/dev/null && [ -z "$TMUX" ]; then
# 	# In SSH sessions, list tmux sessions on log-in.
# 	if [ -n "$SSH_TTY" ]; then
# 		tmux list-sessions 2>/dev/null | sed 's/^/# tmux /'
# 	else
# 		# Auto-attach (or new session)
# 		tmux attach 2>/dev/null || tmux new-session -A -s main
# 	fi
# fi

true
