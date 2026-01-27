# Cross-platform, cross-shell ~/.📂 powered by [Chezmoi](https://www.chezmoi.io/)

## Installation
### Fresh

 `sh -c "$(curl -fsLS get.chezmoi.io)" -- init -S $HOME/.dotfiles --apply rishid`

### Update

Re-apply ansible to machine
`chezmoi -v apply`

## Encrypted Hostname-Specific Config

To add encrypted config for a specific host (e.g., API keys):

```bash
# Create and encrypt hostname-specific fish config
chezmoi encrypt -o $(chezmoi source-path)/private_dot_config/fish/.encrypted-config.$(hostname).fish unencrypted-config.fish
```

The template at `config.{{ .chezmoi.hostname }}.fish.tmpl` will automatically decrypt and apply it.
