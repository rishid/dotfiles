---
name: code-review
description: Use when reviewing code changes before or after opening a PR, checking a branch for issues, or reviewing a GitHub pull request URL/number. Activates for "review my changes", "check my code", "review PR 123", "pre-PR review", "/code-review".
---

# Code Review

Multi-agent code review with adversarial verification. Scales agent count by diff size. Posts inline comments on GitHub PRs or outputs a local report.

## Process

### Step 1: Detect Scope

Determine what to review using this priority:

1. **User specifies PR** — `review PR 123` or a GitHub PR URL → use `gh pr diff <number>`
2. **User specifies commit** — `review commit abc123` → use `git show <sha>`
3. **User specifies files** — `review src/auth.py` → use `git diff HEAD -- <files>`
4. **On a feature branch** — `git diff origin/<base>...HEAD`
5. **On main/master with staged changes** — `git diff --staged`
6. **On main/master, nothing staged** — `git show HEAD`

```bash
# Detect base branch
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main"

# For PR reviews
gh pr view <number> --json baseRefName,headRefName,number,url
gh pr diff <number>
```

If nothing to review, explain and stop.

### Step 2: Gather Context

Run these commands and collect the results:

```bash
DIFF_CMD="<the appropriate git diff command from Step 1>"
CHANGED_FILES=$($DIFF_CMD --name-only)
DIFF_STAT=$($DIFF_CMD --stat)

# Find CLAUDE.md files
find . -name 'CLAUDE.md' -maxdepth 3

# For PR mode, also get PR metadata
gh pr view <number> --json title,body,labels,reviews
```

### Step 3: Launch Workflow

Construct the workflow args and launch:

```
Workflow({
  scriptPath: "<skill-dir>/workflow.js",
  args: {
    diffCommand: "<the diff command from Step 1>",
    changedFiles: ["file1.py", "file2.go"],
    diffStat: "<output of --stat>",
    skillDir: "<absolute path to this skill's directory>",
    claudeMdPaths: ["./CLAUDE.md", "./src/CLAUDE.md"],
  }
})
```

The workflow:
- Scales 3/5/7 agents based on file count (≤3 / ≤15 / >15)
- Runs specialized Sonnet review agents in parallel
- Deduplicates findings (boosts confidence for multi-agent agreement)
- Runs adversarial Haiku verifiers that try to REFUTE each finding
- Returns only findings that survive verification with score ≥ 70

### Step 4: Output Results

**For local reviews** (no PR), format a report:

```markdown
## Code Review

**Branch:** `<branch>` → `<base>`
**Files Changed:** N files (+added/-removed lines)
**Agents:** N review agents, N findings verified

### Issues Found

**1. <title>** (Score: N, Severity: high)
- **Location:** `file.py:42-45`
- **Category:** bug
- **Details:** <description>
- **Evidence:** <evidence>
- **Suggested Fix:**
\`\`\`python
<fix>
\`\`\`

### Summary
- N raw findings → N after dedup → N confirmed after verification
- Checked: bugs, security, failure modes, edge cases, conventions, test gaps

### Verdict: [Clean | Needs Attention | Needs Work]
```

**For PR reviews**, post findings as an inline GitHub review:

```bash
# Build the review JSON
# Each confirmed finding becomes an inline comment at file:line
# Use suggestion blocks for findings that have a suggested_fix

gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews \
  --method POST \
  --field event="<APPROVE|REQUEST_CHANGES|COMMENT>" \
  --field body="## Code Review Summary
N issues found (N critical, N high, N medium)
Reviewed by N specialized agents with adversarial verification." \
  --field 'comments[0][path]=<file>' \
  --field 'comments[0][line]=<line>' \
  --field 'comments[0][body]=**<title>** (<category>, <severity>)

<description>

\`\`\`suggestion
<suggested_fix>
\`\`\`'
```

Verdict mapping:
- **APPROVE** — 0 issues, or only low-severity issues
- **COMMENT** — medium issues only, no critical/high
- **REQUEST_CHANGES** — any critical or high severity issues

Also output a local summary so the user sees results even for PR reviews.

## Language Support

The workflow auto-detects languages from file extensions and loads matching rule files from `rules/`:

| Extensions | Rules File |
|---|---|
| `.py` | `rules/python.md` |
| `.go` | `rules/go.md` |
| `.c`, `.h` | `rules/c.md` |
| `.ts`, `.tsx`, `.js`, `.jsx` | `rules/typescript.md` (if exists) |
| `.rs` | `rules/rust.md` (if exists) |
| Others | `rules/universal.md` only |

`rules/universal.md` is always loaded regardless of language.

## Adding Language Support

Create `rules/<language>.md` following the structure of existing rule files:
- Risk Signals
- Security
- Async/Concurrency
- Resource Management
- Error Handling
- Performance
- Idioms
