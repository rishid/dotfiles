#!/usr/bin/env sh
# @file Shared Profile
# @brief Sourced by ~/.bashrc and ~/.zshrc (not by fish — fish uses conf.d/).

# Homebrew (macOS) — must be set up before exports.sh so brew tools are in PATH
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# SSH Agent setup (for systemd ssh-agent compatibility with VS Code Remote SSH)
[ ! -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/ssh-agent.sh" ] || . "${XDG_CONFIG_HOME:-$HOME/.config}/shell/ssh-agent.sh"

# Aliases / Functions / Exports
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
[ ! -f "${XDG_CONFIG_HOME}/shell/exports.sh" ] || . "${XDG_CONFIG_HOME}/shell/exports.sh"
[ ! -f "${XDG_CONFIG_HOME}/shell/aliases.sh" ] || . "${XDG_CONFIG_HOME}/shell/aliases.sh"
[ ! -f "${XDG_CONFIG_HOME}/shell/functions.sh" ] || . "${XDG_CONFIG_HOME}/shell/functions.sh"

true
