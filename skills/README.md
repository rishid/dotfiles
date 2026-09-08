# Personal agent skills

Custom skills shared across Claude Code, Codex, and OpenCode. Each subdirectory contains a single `SKILL.md`.

They are installed globally for all three agents by the
[chezmoi skills installer](../tilde/.chezmoiscripts/run_onchange_after_install-skills.sh.tmpl)
when running `chezmoi apply`.

## Adding a skill

1. Create `skills/<name>/SKILL.md`
2. Run `chezmoi apply`; the installer already discovers every skill in this directory

## Adding a third-party skill

Add an `add_skill owner/repo --skill skill-name` entry to the
[installer script](../tilde/.chezmoiscripts/run_onchange_after_install-skills.sh.tmpl),
then run `chezmoi apply`. Use the helper instead of a raw `npx skills add` command so
the skill is installed consistently for Claude Code, Codex, and OpenCode.

## Notes

- Encrypted/private skills live in `tilde/dot_claude/skills/` instead (age-encrypted, deployed by chezmoi)
- Third-party skills (Anthropic, Vercel, etc.) are listed in the installer, not stored here
