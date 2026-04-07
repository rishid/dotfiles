# Personal Skills

Custom Claude Code skills tracked in dotfiles. Each subdirectory contains a single `SKILL.md`.

Installed automatically via `run_onchange_after_install-skills.sh.tmpl` when running `chezmoi apply`.

## Adding a skill

1. Create `skills/<name>/SKILL.md`
2. Add `npx skills add "{{ .chezmoi.sourceDir }}/.." -g --all -y` already covers it — no script edit needed
3. `chezmoi apply`

## Notes

- Encrypted/private skills live in `tilde/dot_claude/skills/` instead (age-encrypted, deployed by chezmoi)
- Third-party skills (anthropics, etc.) are listed in the install script, not stored here
