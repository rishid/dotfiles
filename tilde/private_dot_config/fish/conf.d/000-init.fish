# By dictionary order, this file is sourced first in fish shell
# Define user-specific environment variables for fish

# Set XDG basedirs.
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
set -q XDG_CONFIG_HOME; or set -Ux XDG_CONFIG_HOME $HOME/.config
set -q XDG_DATA_HOME; or set -Ux XDG_DATA_HOME $HOME/.local/share
set -q XDG_STATE_HOME; or set -Ux XDG_STATE_HOME $HOME/.local/state
set -q XDG_CACHE_HOME; or set -Ux XDG_CACHE_HOME $HOME/.cache

# Tide starts noninteractive fish processes to render the prompt. Make Fisher's
# functions available as soon as fish loads conf.d, before config.fish runs.
set --global fisher_path "$__fish_config_dir/plugins"
if not contains -- "$fisher_path/functions" $fish_function_path
    set fish_function_path $fish_function_path[1] "$fisher_path/functions" $fish_function_path[2..]
end
