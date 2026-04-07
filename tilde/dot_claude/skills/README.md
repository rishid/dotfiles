# Claude Skills

Skills are managed via chezmoi + `npx skills`. The source of truth is
`.chezmoiscripts/run_onchange_after_install-skills.sh.tmpl`.

## Adding a skill (best practice)

```fish
chezmoi edit ~/.dotfiles/tilde/.chezmoiscripts/run_onchange_after_install-skills.sh.tmpl
# add: npx skills add <source> -g -y
chezmoi apply
```

Chezmoi detects the file changed and re-runs the script, which installs the skill.

## Skill types

**Third-party** (GitHub): Add a line to the script.
```bash
npx skills add anthropics/skills@claude-api -g -y
```

**Private/local**: Add the SKILL.md files to `tilde/dot_claude/skills/<name>/` via chezmoi,
then add a reference line to the script using the deployed path:
```bash
npx skills add "{{ .chezmoi.homeDir }}/.claude/skills/<name>" -g -y
```
Chezmoi deploys the files first (it's an `after` script), so the path exists when the script runs.

## Day-to-day commands

| Command | Description |
|---|---|
| `skill-install <source>` | Install immediately + commit (bypasses the script) |
| `skill-update [skill\|--all]` | Update skill(s) and sync to dotfiles |
| `skill-remove <skill>` | Remove skill and commit to dotfiles |
| `skill-list` | List installed skills |

## Why not `{{ .chezmoi.sourceDir }}`?

Chezmoi stores `.claude/skills/` as `dot_claude/skills/` in source, so npx skills can't
discover skills there. The deployed target (`~/.claude/skills/`) works because `after`
scripts run after file deployment.
