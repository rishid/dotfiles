---
name: code-review
description: Use when reviewing code changes before or after opening a PR, checking a branch for issues, or reviewing a GitHub pull request URL/number. Activates for "review my changes", "check my code", "review PR 123", "pre-PR review", "/code-review".
---

# Code Review

Multi-agent code review with adversarial verification. Scales agent count by diff size. Posts inline comments on GitHub PRs or outputs a local report.

## Process

### Step 1: Detect Scope

Determine what to review:

1. **User specifies PR** — `review PR 123` or a GitHub PR URL → scope is `pr`
2. **User specifies commit** — `review commit abc123` → scope is `commit`
3. **On a feature branch** (not main/master) → scope is `branch`
4. **On main/master with staged changes** → scope is `staged`
5. **On main/master, nothing staged** → scope is `commit`

For PR reviews, extract the repo (`owner/repo`) and PR number from the URL or user input. If not obvious, run:
```bash
gh repo view --json nameWithOwner -q .nameWithOwner
```

### Step 2: Launch Workflow

Use the `Workflow` tool with `workflow.js` from this skill's directory. Pass **minimal args** — the workflow's context agent handles gathering the diff, changed files, and stats.

**CRITICAL:** The `args` parameter MUST be a JSON object, NOT a JSON string. The Workflow tool accepts raw JSON values.

**For PR reviews:**
```
Workflow({
  scriptPath: "<this skill's directory>/workflow.js",
  args: {
    "scope": "pr",
    "repo": "owner/repo",
    "prNumber": 123,
    "skillDir": "<absolute path to this skill's directory>"
  }
})
```

**For local reviews:**
```
Workflow({
  scriptPath: "<this skill's directory>/workflow.js",
  args: {
    scope: "branch",
    skillDir: "<absolute path to this skill's directory>"
  }
})
```

Valid scope values: `"pr"`, `"branch"`, `"staged"`, `"commit"`

The workflow:
- Gathers context via a Haiku agent (diff, changed files, CLAUDE.md files)
- Scales 3/5/7 review agents based on file count (≤3 / ≤15 / >15)
- Runs specialized Sonnet review agents in parallel
- Deduplicates findings (boosts confidence for multi-agent agreement)
- Runs adversarial Haiku verifiers that try to REFUTE each finding
- Returns only findings surviving verification with score ≥ 70
- Returns `{ confirmed: [...findings], stats: {...} }`

### Step 3: Output Results

**For local reviews**, format a markdown report:

```markdown
## Code Review

**Branch:** `<branch>` → `<base>`
**Files Changed:** N files (+added/-removed lines)
**Agents:** N review agents

### Issues Found

**1. <title>** (Severity: high, Score: N)
- **Location:** `file.py:42-45`
- **Category:** bug
- **Details:** <description>
- **Evidence:** <evidence>
- **Suggested Fix:**
\`\`\`python
<fix>
\`\`\`

### Summary
N raw findings → N after dedup → N challenged by adversarial verifiers → N survived

### Verdict: [Clean | Needs Attention | Needs Work]
```

**For PR reviews**, post findings as a GitHub review using JSON input.

CRITICAL: Use `--input -` with a heredoc. The `--field 'comments[0][...]'` syntax does NOT produce valid JSON arrays and GitHub will reject it.

**Inline suggestion rules:**
- `suggested_fix` MUST be the actual replacement code for those exact lines — not a description, not a pointer. GitHub's "Apply suggestion" button replaces the highlighted lines verbatim with whatever is in the suggestion block.
- If the fix is not a clean line replacement (e.g. a multi-file change, or adding a new function elsewhere), do NOT use a suggestion block. Use a plain code block instead.
- For findings with suggestions, also include a link to the file+line in the PR review body so the author can navigate directly.

```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews \
  --method POST --input - <<'EOF'
{
  "event": "<APPROVE|REQUEST_CHANGES|COMMENT>",
  "body": "## Code Review\n\nN issues found (N critical, N high). Reviewed by N specialized agents with adversarial verification.\n\n### Issues\n- [**Title 1**](https://github.com/{owner}/{repo}/blob/{head_sha}/src/file.py#L42) — brief reason\n- [**Title 2**](https://github.com/{owner}/{repo}/blob/{head_sha}/src/file2.py#L87) — brief reason",
  "comments": [
    {
      "path": "src/file.py",
      "line": 42,
      "body": "**Title** (category, severity)\n\nDescription of the issue and why it matters.\n\n```suggestion\nexact replacement code for these lines\n```"
    },
    {
      "path": "src/file2.py",
      "line": 87,
      "body": "**Title** (category, severity)\n\nDescription. Fix requires changes in multiple places — see summary above.\n\n```python\n// example of the fix pattern\n```"
    }
  ]
}
EOF
```

Build the review:
- `body` = summary with a linked list of all findings (`[Title](github-url#Lline)`)
- `comments[].path` = finding.file
- `comments[].line` = finding.line_end
- `comments[].body` = title, description, then either a `suggestion` block (if fix is a clean line replacement) or a plain code block (if fix spans multiple locations)
- To build file links: get the PR head SHA with `gh pr view {number} --repo {repo} --json headRefOid -q .headRefOid`

Verdict mapping:
- **APPROVE** — 0 confirmed issues
- **COMMENT** — only medium/low severity issues
- **REQUEST_CHANGES** — any critical or high severity issues

Always show a local summary too so the user sees results even for PR reviews.

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
