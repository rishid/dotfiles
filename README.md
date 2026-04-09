# Cross-platform dotfiles powered by [Chezmoi](https://www.chezmoi.io/)

## macOS Setup (Fresh Machine)

Run the bootstrap script — it installs Xcode CLT, Homebrew, fish, chezmoi, and applies dotfiles in one shot:

```bash
curl -fsSL https://raw.githubusercontent.com/rishid/dotfiles/master/bootstrap-macos.sh | bash
```

Or clone first and run locally:

```bash
git clone https://github.com/rishid/dotfiles.git /tmp/dotfiles
bash /tmp/dotfiles/bootstrap-macos.sh
```

> **Note:** You'll need your age private key at `~/.config/chezmoi/key.txt` to decrypt secrets.
> Copy it from another machine before running, or the script will prompt you.

## Linux / Update

```bash
# Fresh install
sh -c "$(curl -fsLS get.chezmoi.io)" -- init -S $HOME/.dotfiles --apply rishid

# Update (re-apply)
chezmoi update   # or abbreviation: cu
chezmoi apply    # or abbreviation: ca
```

## After bootstrap: install dev tools

```bash
mise install   # installs all tools from ~/.config/mise/config.toml
```

## Encrypted Hostname-Specific Config

To add encrypted config for a specific host (e.g., API keys):

```bash
# Create and encrypt hostname-specific fish config
chezmoi encrypt -o $(chezmoi source-path)/private_dot_config/fish/.encrypted-config.$(hostname).fish unencrypted-config.fish
```

The template at `config.{{ .chezmoi.hostname }}.fish.tmpl` will automatically decrypt and apply it.
