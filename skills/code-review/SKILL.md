---
name: code-review
description: Use when reviewing code changes before or after opening a PR, checking a branch for issues, or reviewing a GitHub pull request URL/number. Activates for "review my changes", "check my code", "review PR 123", "pre-PR review", "/code-review".
---

# Code Review

Multi-agent code review with adversarial verification. Scales agent count by diff size. Posts inline comments on GitHub PRs or outputs a local report.

## Process

### Step 1: Detect Scope & Gather Context

Determine what to review and collect all context before launching the workflow.

**Scope priority:**

1. **User specifies PR** — `review PR 123` or a GitHub PR URL
2. **User specifies commit** — `review commit abc123`
3. **User specifies files** — `review src/auth.py`
4. **On a feature branch** — diff against base
5. **On main/master with staged changes** — staged diff
6. **On main/master, nothing staged** — latest commit

**For PR reviews:**

```bash
# Get PR metadata
REPO="<owner/repo>"  # from gh repo view or PR URL
PR_NUM=<number>
gh pr view $PR_NUM --repo $REPO --json baseRefName,headRefName,number,url,title

# Get diff — this is the diffCommand for PR reviews
gh pr diff $PR_NUM --repo $REPO

# Get changed files
gh pr diff $PR_NUM --repo $REPO --name-only

# Get diff stats (line count from diff)
gh pr diff $PR_NUM --repo $REPO | grep -c '^[+-]' || echo "unknown"
```

**For local branch reviews:**

```bash
BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
# diffCommand: git diff origin/$BASE...HEAD
git diff --name-only origin/$BASE...HEAD
git diff --stat origin/$BASE...HEAD
```

Also find project guidelines:

```bash
find . -name 'CLAUDE.md' -maxdepth 3 -not -path '*/node_modules/*'
```

If nothing to review, explain and stop.

### Step 2: Launch Workflow

Use the `Workflow` tool with `workflow.js` from this skill's directory.

**IMPORTANT:** All args must be populated from Step 1. `changedFiles` and `claudeMdPaths` MUST be JSON arrays, not strings.

For **PR reviews**, set `diffCommand` to the `gh pr diff` command (including `--repo` flag):

```
Workflow({
  scriptPath: "<this skill's directory>/workflow.js",
  args: {
    diffCommand: "gh pr diff 123 --repo owner/repo",
    changedFiles: ["src/foo.py", "src/bar.go"],
    diffStat: "5 files changed, 120 insertions(+), 30 deletions(-)",
    skillDir: "<absolute path to this skill's directory>",
    claudeMdPaths: ["./CLAUDE.md"],
    repo: "owner/repo",
    prNumber: 123
  }
})
```

For **local reviews**, set `diffCommand` to the git diff command:

```
Workflow({
  scriptPath: "<this skill's directory>/workflow.js",
  args: {
    diffCommand: "git diff origin/main...HEAD",
    changedFiles: ["src/foo.py", "src/bar.go"],
    diffStat: "3 files changed, 50 insertions(+), 20 deletions(-)",
    skillDir: "<absolute path to this skill's directory>",
    claudeMdPaths: ["./CLAUDE.md"]
  }
})
```

The workflow returns `{ confirmed: [...findings], stats: {...} }`.

### Step 3: Output Results

**For local reviews**, format a markdown report:

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
N raw findings → N after dedup → N confirmed after verification

### Verdict: [Clean | Needs Attention | Needs Work]
```

**For PR reviews**, post findings as a GitHub review using JSON input:

```bash
# Build a JSON file with the review body and inline comments.
# CRITICAL: Use --input with a heredoc — --field syntax does NOT work for comment arrays.

gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews \
  --method POST --input - <<'EOF'
{
  "event": "<APPROVE|REQUEST_CHANGES|COMMENT>",
  "body": "## Code Review Summary\n\nN issues found. Reviewed by N agents with adversarial verification.",
  "comments": [
    {
      "path": "src/file.py",
      "line": 42,
      "body": "**Title** (category, severity — Score: N)\n\nDescription.\n\n```suggestion\nsuggested fix code\n```"
    }
  ]
}
EOF
```

Build the `comments` array from the workflow's `confirmed` findings:
- `path` = finding.file
- `line` = finding.line_end (GitHub uses the last line of the range)
- `body` = formatted finding with title, description, and suggestion block if `suggested_fix` exists

Verdict mapping:
- **APPROVE** — 0 confirmed issues
- **COMMENT** — only medium/low severity issues
- **REQUEST_CHANGES** — any critical or high severity issues

Always output a local summary too, so the user sees results even for PR reviews.

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
- Risk Signals, Security, Async/Concurrency, Resource Management, Error Handling, Performance, Idioms
