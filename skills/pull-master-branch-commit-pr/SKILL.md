---
name: ship
description: >
  Use when the user says "ship this", "pull master, branch, commit and PR",
  "branch and PR", "/commit", "commit this", or any variation meaning: sync
  with master, create a feature branch, commit changes with a conventional
  commit message, and open a PR. Handles dirty trees, existing branches,
  merge conflicts, and smart staging automatically.
allowed-tools: Bash
---

# Ship: Pull → Branch → Commit → PR

## Context strategy
**Run this entire workflow inside a `Task` subagent.** Spawn it with the goal
below and only surface the PR URL (or error) to the main context. This keeps
the main conversation clean.

---

## Workflow

### 0. Pre-flight
```bash
git status --porcelain
git diff --stat
```
- If there are no changes (nothing staged, nothing modified), stop and tell the
  user there's nothing to ship.
- Identify any secrets before staging: never commit `.env`, `*.pem`,
  `credentials.*`, or private keys. Warn and exclude if found.

### 1. Sync with master (if not already on a feature branch)

**If already on a feature branch** → skip to step 3. Don't re-branch.

**If on master with a dirty tree:**
```bash
git stash
git pull
# (branch, then) git stash pop
```

**If on master and clean:**
```bash
git pull
```

**If `git pull` hits a merge conflict:** Stop. Tell the user which files
conflict and ask them to resolve before continuing.

### 2. Create branch
Check `CLAUDE.md` or repo conventions first. Default naming:
- `feature/` — new capability
- `fix/` — bug fix
- `chore/` — maintenance, deps, config
- `hotfix/` — urgent production patch

**Derive the slug from the diff**, not from a generic label. If context is
ambiguous (e.g. changes span multiple unrelated areas), ask the user for a
one-line description before proceeding.

```bash
git checkout -b <type>/<slug>
git stash pop   # only if stash was used in step 1
```

### 3. Stage files
```bash
git diff --stat
git status --porcelain
```
Stage only files relevant to the current change:
```bash
git add path/to/file1 path/to/file2   # by path, never `git add .` blindly
```
If the diff spans logically unrelated changes, stage and commit them
separately rather than bundling everything.

### 4. Analyze diff and generate commit message

```bash
git diff --staged
```

**Conventional Commits format:**
<type>[optional scope]: <description>
[optional body — the WHY, not the what]
[optional footer: Closes #123, BREAKING CHANGE: ...]

| Type | Use for |
|------|---------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Docs only |
| `style` | Formatting, no logic change |
| `refactor` | Restructure, no feature/fix |
| `perf` | Performance |
| `test` | Tests |
| `build` | Build system / deps |
| `ci` | CI config |
| `chore` | Maintenance / misc |

Rules:
- Description: imperative mood, present tense, ≤72 chars
- Body: explain *why*, not *what* (the diff already shows what)
- Breaking change: add `!` after type (`feat!:`) and/or `BREAKING CHANGE:` footer

### 5. Pre-push checks
If the repo has a lint/test script, run it before pushing:
```bash
# Check for common script entry points
cat package.json | grep -E '"(lint|test|check)"'
make help 2>/dev/null | head -20
```
Run the relevant check and surface failures before pushing.

### 6. Commit and push
```bash
git commit -m "$(cat <<'EOF'
<type>[scope]: <description>

<body if needed>

<footer if needed>
EOF
)"

git push -u origin <branch>
```

### 7. Open PR
```bash
gh pr create \
  --title "<same as commit subject>" \
  --body "$(cat <<'EOF'
## Summary
- <bullet: what changed and why>
- <bullet>

## Test plan
- [ ] <how to verify this works>
- [ ] <edge case tested>

## Notes for reviewer
<anything non-obvious: tradeoffs made, things left out intentionally, follow-ups>
EOF
)"
```
- Add `--draft` if the branch isn't ready for review but CI should run
- If a ticket/issue number is detectable from branch name or commit context,
  add `Closes #N` to the PR body footer

### 8. Return PR URL
Output only the PR URL to the parent context. Nothing else.

---

## Safety rules
- Never `git config` changes
- Never `--force` push to main/master
- Never `--no-verify` unless user explicitly asks
- Never `git add .` without reviewing status first
- If a commit hook fails, fix the issue and create a new commit — never amend
  a pushed commit
