---
name: pull-master-branch-commit-pr
description: Use when the user says "pull master, branch, commit and pr", "ship this", "branch and PR", or any variation meaning: sync with master, create a feature branch, commit current changes, and open a PR.
---

# Pull Master → Branch → Commit → PR

Automates the standard workflow for shipping work-in-progress changes to a PR.

## Steps

1. **Verify master is up to date** — if already on master and up to date, skip pull. Otherwise:
   ```bash
   git checkout master && git pull
   ```

2. **Create branch** — use the project's naming convention (check memory/CLAUDE.md):
   - `feature/short-description` for new features
   - `bugfix/short-description` for fixes
   - `hotfix/short-description` for urgent patches
   - Derive the description from the work being shipped (kebab-case, concise)

3. **Stage only the relevant changed files** — never `git add .` blindly. Check `git status` and stage only files related to the current work. Leave unrelated staged/unstaged files alone.

4. **Commit** with a conventional commit message:
   - `feat:`, `fix:`, `chore:`, etc.
   - Subject line: what changed (imperative mood, ≤72 chars)
   - Body: *why*, including any non-obvious decisions (e.g. "X-Forwarded-For ignored — spoofable")

5. **Push and create PR**:
   ```bash
   git push -u origin <branch>
   gh pr create --title "..." --body "..."
   ```
   PR body: ## Summary (bullets), ## Test plan (checklist).

6. **Return the PR URL** so the user can navigate to it.

## Common Mistakes

- Staging unrelated files (config/, docs/ that aren't part of the task)
- Vague branch names (`feature/update`, `fix/stuff`)
- Commit message describes *what* git diff already shows, not *why*
- Forgetting to return the PR URL
