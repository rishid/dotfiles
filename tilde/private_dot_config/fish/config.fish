
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

# Activate mise (must come before direnv and other tool usage)
# Use a more reliable mise activation method
if command -v mise >/dev/null 2>&1
    # Use mise's built-in fish activation
    mise activate fish | source

    # Verify activation worked by checking if MISE_SHELL is set
    if test -z "$MISE_SHELL"
        # Fallback: try direct eval
        eval (mise activate fish)
    end
else if test -x "$HOME/.local/bin/mise"
    # Fallback to explicit path
    eval ($HOME/.local/bin/mise activate fish)
end

# Now direnv should be available via mise
if command -v direnv >/dev/null 2>&1
    direnv hook fish | source
end

#source ~/.config/shell/aliases.sh

if test -f "$__fish_config_dir/config.(hostname).fish"
  source "$__fish_config_dir/config.(hostname).fish"
end

if test -f "$__fish_config_dir/config.local.fish"
  source "$__fish_config_dir/config.local.fish"
end
