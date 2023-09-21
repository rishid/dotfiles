

### Globals
set --global --export LC_ALL "en_US.UTF-8"
set --global --export LANG "$LC_ALL"

set --global --export XDG_CONFIG_HOME "$HOME/.config"
set --global --export XDG_CACHE_HOME "$HOME/.cache"
set --global --export XDG_DATA_HOME "$HOME/.local/share"
set --global --export XDG_STATE_HOME "$HOME/.local/state"

source "$XDG_CONFIG_HOME/shell/exports.sh"

source "$__fish_config_dir/variables.fish"

# automatically loads plugins under "$fisher_path"
source "$__fish_config_dir/functions/fisher_path.fish"

# Install fisher, if not exist
if status is-interactive && ! functions --query fisher
  curl -sL https://git.io/fisher | source && fisher update
end

fish_add_path --global "$HOME/.local/bin/"

set -Ux EDITOR emacs

#source ~/.config/shell/aliases.sh
