---
name: dotfiles
description: Chezmoi dotfiles conventions and patterns. Use when modifying dotfiles, adding new managed files, or working with chezmoi templates.
allowed-tools: Read Grep Glob Bash
---

# Chezmoi Dotfiles Conventions

## File Naming

- `dot_` prefix maps to `.` (e.g., `dot_bashrc` → `~/.bashrc`)
- `private_` prefix sets restrictive permissions (e.g., `private_dot_ssh/`)
- `.tmpl` suffix indicates a chezmoi template using Go text/template syntax
- `run_once_before_` / `run_once_after_` scripts run once during `chezmoi apply`
- `run_onchange_` scripts re-run when their content changes
- `encrypted_` prefix + `.age` suffix indicates age-encrypted files

## Templates

Templates use Go `text/template` with chezmoi data:

```
{{ .chezmoi.os }}
{{ .chezmoi.hostname }}
{{ .chezmoi.homeDir }}
{{ .chezmoi.sourceDir }}   # → ~/.dotfiles/tilde/ (chezmoiroot is "tilde")
{{ if eq .chezmoi.os "linux" }}linux-specific{{ end }}
```

## Structure

- `tilde/` → chezmoi source root (set via `.chezmoiroot`)
- `tilde/private_dot_config/fish/` → `~/.config/fish/` (Fish shell config)
- `tilde/private_dot_config/shell/` → `~/.config/shell/` (POSIX shared config)
- `tilde/dot_claude/` → `~/.claude/` (Claude Code settings, encrypted private skills)
- `tilde/.chezmoiscripts/` → chezmoi lifecycle scripts
- `skills/` → personal Claude skills (at repo root, installed via npx)

## Workflow

1. Edit source files in `~/.dotfiles/tilde/`
2. Preview changes: `chezmoi diff`
3. Apply changes: `chezmoi apply` (abbreviation: `ca`)
4. Add existing file: `chezmoi add <file>`
5. Edit encrypted file: `chezmoi edit <target-path>`

## Managing Skills

Skills are split between two locations:

- `skills/` (repo root) — personal, non-sensitive skills; auto-installed via `run_onchange_after_install-skills.sh.tmpl`
- `tilde/dot_claude/skills/` — encrypted private skills (age); deployed by chezmoi

To add a personal skill: create `skills/<name>/SKILL.md` and run `chezmoi apply`.
