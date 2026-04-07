# Claude Skills

Skills are managed via `npx skills` + chezmoi for cross-machine persistence.

## Commands

| Command | Description |
|---|---|
| `skill-install <source>` | Install skill and commit to dotfiles |
| `skill-update [skill\|--all]` | Update skill(s) and sync to dotfiles |
| `skill-remove <skill>` | Remove skill and commit to dotfiles |
| `skill-list` | List installed skills |

## Installing a Skill

```fish
# From a specific skill in a repo
skill-install anthropics/skills@frontend-design

# Browse and select from a multi-skill repo
skill-install anthropics/skills
```

## Updating Skills

```fish
skill-update frontend-design   # update one skill
skill-update --all             # update all skills
```

## How It Works

1. `npx skills add --copy` installs real files (not symlinks) to `~/.claude/skills/`
2. `chezmoi add` tracks the skills directory and lockfile in dotfiles
3. A git commit records the change with a descriptive message
4. On new machines, `chezmoi apply` restores all skills automatically

## Lockfile

`~/.claude/.skills-lock.json` pins exact versions and integrity hashes. It is committed alongside skills for supply chain security and reproducibility.

## Adding Skills Manually

If a skill isn't in the `npx skills` ecosystem, add it manually:

```fish
cp -r /path/to/skill ~/.claude/skills/my-skill/
chezmoi add ~/.claude/skills/
cd ~/.dotfiles && git add . && git commit -m "feat(skill): add my-skill"
```
