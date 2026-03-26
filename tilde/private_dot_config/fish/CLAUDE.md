# Fish Config — Hostname-Specific Encrypted Files

## How it works

Host-specific env vars (e.g. API keys, internal URLs) are stored **age-encrypted** in the source
directory and rendered only on the matching host via a chezmoi template.

### File roles

| Source file | Target file | Purpose |
|---|---|---|
| `config.bos-lhv9i4.fish.tmpl` | `~/.config/fish/config.bos-lhv9i4.fish` | Template: decrypts and renders the encrypted file for host `bos-lhv9i4` only |
| `.encrypted-config.bos-lhv9i4.fish` | _(no target — source only)_ | Age-encrypted env vars for host `bos-lhv9i4` |

### Why `.encrypted-config.*.fish` files have no chezmoi target

The encrypted files live in the chezmoi source dir but are **not** managed by chezmoi as targets
themselves. They are referenced directly by the `.tmpl` file via `include ... | decrypt`.
This is why they are listed in `.chezmoiignore` — to prevent chezmoi from trying to deploy them.

### Template pattern

```
{{- if eq .chezmoi.hostname "bos-lhv9i4" -}}
{{ include (joinPath .chezmoi.sourceDir "private_dot_config/fish/.encrypted-config.bos-lhv9i4.fish") | decrypt }}
{{- end -}}
```

---

## Editing an encrypted config file

### Decrypt → edit → re-encrypt

```fish
# 1. Decrypt to a temp file
age --decrypt -i ~/.config/chezmoi/key.txt \
  ~/.dotfiles/tilde/private_dot_config/fish/.encrypted-config.bos-lhv9i4.fish \
  > /tmp/claude-config.fish

# 2. Edit the temp file
$EDITOR /tmp/claude-config.fish

# 3. Re-encrypt back into the source
age --encrypt \
  -r age17z6sdx7ceu7xu4llsdt4gakyuzkhvqe9vr226jjvg8rr0j57ta3qd5ry67 \
  -o ~/.dotfiles/tilde/private_dot_config/fish/.encrypted-config.bos-lhv9i4.fish \
  /tmp/claude-config.fish

# 4. Apply to deploy
chezmoi apply ~/.config/fish/config.bos-lhv9i4.fish

# 5. Verify
cat ~/.config/fish/config.bos-lhv9i4.fish

# 6. Commit
cd ~/.dotfiles && git add tilde/private_dot_config/fish/.encrypted-config.bos-lhv9i4.fish
git commit -m "chore: update encrypted config for bos-lhv9i4"

# 7. Clean up
rm /tmp/claude-config.fish
```

### View current decrypted content (without editing)

```fish
age --decrypt -i ~/.config/chezmoi/key.txt \
  ~/.dotfiles/tilde/private_dot_config/fish/.encrypted-config.bos-lhv9i4.fish
```

### Add a new host

1. Create the encrypted file for the new host:
   ```fish
   age --encrypt -r age17z6sdx7ceu7xu4llsdt4gakyuzkhvqe9vr226jjvg8rr0j57ta3qd5ry67 \
     -o ~/.dotfiles/tilde/private_dot_config/fish/.encrypted-config.NEWHOSTNAME.fish \
     /tmp/your-config.fish
   ```
2. Create a template `config.NEWHOSTNAME.fish.tmpl` with the same pattern above.
3. Add `.encrypted-config.NEWHOSTNAME.fish` to `.chezmoiignore`.

---

## Key locations

| Item | Path |
|---|---|
| Age identity (private key) | `~/.config/chezmoi/key.txt` |
| Age recipient (public key) | `age17z6sdx7ceu7xu4llsdt4gakyuzkhvqe9vr226jjvg8rr0j57ta3qd5ry67` |
| chezmoi config | `~/.dotfiles/tilde/.chezmoi.yaml.tmpl` |
