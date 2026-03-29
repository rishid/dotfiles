# Dotfiles — Claude Context

## Structure

| Path | Purpose |
|---|---|
| `tilde/` | chezmoi source root (maps to `~/`) |
| `tilde/.chezmoiscripts/` | Scripts run by chezmoi on apply |
| `tilde/private_dot_config/fish/` | Fish shell config |
| `tilde/private_dot_config/shell/` | POSIX-compatible shared shell config (sourced by fish + bash) |
| `docs/` | Documentation |

## Chezmoi

Source dir is `tilde/` (set via `.chezmoiroot`). To apply changes:

```fish
chezmoi apply   # or abbreviation: ca
chezmoi update  # pull from git + apply: cu
```

Encrypted files use age. Identity at `~/.config/chezmoi/key.txt`.

## Fish Shell

- `config.fish` sources `variables.fish` (tide/fisher config) and `functions/fisher_path.fish` (loads plugins from `~/.config/fish/plugins/`)
- Fisher plugins are managed in `fish_plugins`; the chezmoi script `run_onchange_after_install-fisher.fish.tmpl` runs `fisher update` whenever `fish_plugins` changes
- `jorgebucaran/fisher` must be listed in `fish_plugins` so fisher persists to `$fisher_path/functions/fisher.fish` across sessions

## Hostname-specific config

`config.fish` sources `~/.config/fish/config.<hostname>.fish` if it exists. These are age-encrypted and managed per-host. See `tilde/private_dot_config/fish/CLAUDE.md` for details.
