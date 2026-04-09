
# Shared environment variables file
# This file is sourced by fish and bash
source "$XDG_CONFIG_HOME/shell/exports.sh"

source "$__fish_config_dir/variables.fish"

# automatically loads plugins under "$fisher_path"
source "$__fish_config_dir/functions/fisher_path.fish"

fish_add_path --global "$HOME/.local/bin/"

set -Ux EDITOR "code --wait"

# Activate mise (must come before direnv and other tool usage)
if command -v mise >/dev/null 2>&1
    mise activate fish | source
else if test -x "$HOME/.local/bin/mise"
    $HOME/.local/bin/mise activate fish | source
end

# Now direnv should be available via mise
if command -v direnv >/dev/null 2>&1
    direnv hook fish | source
end

#source ~/.config/shell/aliases.sh

if test -f "$__fish_config_dir/config.$(hostname).fish"
  source "$__fish_config_dir/config.$(hostname).fish"
end

if test -f "$__fish_config_dir/config.local.fish"
  source "$__fish_config_dir/config.local.fish"
end
