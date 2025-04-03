
# Shared environment variables file
# This file is sourced by fish and bash
source "$XDG_CONFIG_HOME/shell/exports.sh"

source "$__fish_config_dir/variables.fish"

# automatically loads plugins under "$fisher_path"
source "$__fish_config_dir/functions/fisher_path.fish"

# Install fisher, if not exist
if status is-interactive && ! functions --query fisher
  curl -sL https://git.io/fisher | source && fisher update
end

fish_add_path --global "$HOME/.local/bin/"

set -Ux EDITOR "code --wait"

direnv hook fish | source

#source ~/.config/shell/aliases.sh

if test -f "$__fish_config_dir/config.local.fish"
  source "$__fish_config_dir/config.local.fish"
end
