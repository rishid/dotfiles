# Fish Config — Hostname-Specific Encrypted Files

## How it works

Host-specific env vars (e.g. API keys, internal URLs) are stored **age-encrypted** as native
chezmoi-managed files. `config.fish` sources `config.$(hostname).fish` automatically, so chezmoi
just needs to deploy the right file — no hostname logic needed in chezmoi itself.

```fish
# config.fish (already present)
if test -f "$__fish_config_dir/config.$(hostname).fish"
  source "$__fish_config_dir/config.$(hostname).fish"
end
```

### File roles

| Source file | Target file | Purpose |
|---|---|---|
| `encrypted_config.bos-lhv9i4.fish.age` | `~/.config/fish/config.bos-lhv9i4.fish` | Age-encrypted env vars for host `bos-lhv9i4`, deployed by chezmoi to all hosts, sourced only on matching host by fish |

The file is deployed to **all hosts** by chezmoi but only sourced on `bos-lhv9i4` by fish.
Each host gets its own `encrypted_config.HOSTNAME.fish.age` with its own keys.

---

## Editing an encrypted config file

### Using chezmoi edit (recommended)

```fish
chezmoi edit ~/.config/fish/config.bos-lhv9i4.fish
# Opens decrypted content in $EDITOR, re-encrypts and applies on save
```

### Manually with age (alternative)

```fish
# Decrypt, edit, re-encrypt
age --decrypt -i ~/.config/chezmoi/key.txt \
  ~/.dotfiles/tilde/private_dot_config/fish/encrypted_config.bos-lhv9i4.fish.age \
  > /tmp/cfg.fish && $EDITOR /tmp/cfg.fish

chezmoi add --encrypt ~/.config/fish/config.bos-lhv9i4.fish
# (after writing new content to the target)
rm /tmp/cfg.fish
```

### View current decrypted content

```fish
chezmoi cat ~/.config/fish/config.bos-lhv9i4.fish
```

---

## Adding a new host

```fish
# 1. Create the config for the new host
set hostname (hostname)
cat > /tmp/cfg.fish << EOF
export SOME_API_KEY="your-key-here"
export SOME_URL="https://..."
EOF

# 2. Copy to target location
cp /tmp/cfg.fish ~/.config/fish/config.$hostname.fish

# 3. Let chezmoi encrypt and manage it
chezmoi add --encrypt ~/.config/fish/config.$hostname.fish

rm /tmp/cfg.fish
```

---

## Key locations

| Item | Path |
|---|---|
| Age identity (private key) | `~/.config/chezmoi/key.txt` |
| Age recipient (public key) | `age17z6sdx7ceu7xu4llsdt4gakyuzkhvqe9vr226jjvg8rr0j57ta3qd5ry67` |
| chezmoi config | `~/.dotfiles/tilde/.chezmoi.yaml.tmpl` |
