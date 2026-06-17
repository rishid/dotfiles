---
name: dependabot-pr-merge
description: Find open Dependabot PRs for a GitHub repo, review CI status, and approve+merge them one at a time.
user-invocable: true
argument-hint: "OWNER/REPO or GitHub URL (omit to infer from current repo)"
allowed-tools: Bash, AskUserQuestion
---

# Dependabot PR Merge

Review and merge open Dependabot PRs for a GitHub repository. Iterates through each PR one at a time, checking CI status before prompting to approve and merge.

## Prerequisites

- `gh` CLI installed and authenticated
- Token needs `repo` scope (for PR approval and merge)

## Step 1: Resolve Repository

Determine `OWNER/REPO` from the input:

**If `$ARGUMENTS` is provided**, parse it:
- `OWNER/REPO` format → use directly
- `https://github.com/OWNER/REPO/...` URL → extract OWNER/REPO
- `OWNER REPO` (space-separated) → join as OWNER/REPO

**If no arguments**, infer from current directory:
```bash
gh repo view --json nameWithOwner --jq '.nameWithOwner'
```

Confirm the resolved repo with the user before proceeding.

## Step 2: List Open Dependabot PRs

```bash
gh pr list --repo OWNER/REPO --author "app/dependabot" --state open \
  --json number,title,url,headRefName,createdAt,additions,deletions \
  --jq 'sort_by(.number)'
```

If no PRs found, report "No open Dependabot PRs for OWNER/REPO" and stop.

Otherwise, show a summary table: count of open PRs, list of PR numbers + titles.

## Step 3: Iterate One at a Time

For each PR in order (oldest first):

### 3a. Show PR Details

```bash
gh pr view NUMBER --repo OWNER/REPO \
  --json title,url,body,additions,deletions,headRefName,createdAt
```

Display: PR number, title, URL, what dependency is being bumped (parse from title/body), and diff size.

### 3b. Check CI Status

```bash
gh pr checks NUMBER --repo OWNER/REPO
```

Interpret the results:

| Status | Action |
|--------|--------|
| All checks pass | Proceed to 3c (merge prompt) |
| Some checks pending | Report which checks are pending. Proceed to 3c (retry prompt) |
| Any check failed | Report failures. Proceed to 3c (retry prompt) |
| No checks configured | Warn that there are no required checks. Proceed to 3c (merge prompt) |

### 3c. Prompt User

**If checks pass (or no checks configured)** — automatically proceed to 3d without prompting. Do NOT ask the user for confirmation; just approve and merge.

**If checks pending or failed** — use `AskUserQuestion` with:
- **Re-run failed checks** — re-run only the failed/pending workflow runs without changing the branch (good for flaky tests)
- **Update branch & re-run** — update the PR branch with latest base branch changes, which triggers a full fresh CI run (good when the base branch has fixes since the PR was created)
- **Skip** — move to the next PR
- **Stop** — end the skill, show summary

#### Re-run failed checks

Find the failed/pending workflow run IDs from the PR's head commit and re-run them:

```bash
# Get the head SHA
HEAD_SHA=$(gh pr view NUMBER --repo OWNER/REPO --json headRefOid --jq '.headRefOid')

# List check runs that failed or are pending
gh api "repos/OWNER/REPO/commits/${HEAD_SHA}/check-runs" \
  --jq '.check_runs[] | select(.conclusion == "failure" or .conclusion == null) | .id'

# Re-run the associated workflow runs
gh run rerun RUN_ID --repo OWNER/REPO --failed
```

After triggering re-runs, report what was re-triggered and move to the next PR. The user can re-invoke the skill later to merge PRs whose checks now pass.

#### Update branch & re-run

```bash
gh api -X PUT "repos/OWNER/REPO/pulls/NUMBER/update-branch" \
  -f update_method="rebase"
```

This rebases the PR onto the latest base branch, which triggers a full CI run. After triggering, report and move to the next PR. The user can re-invoke the skill later to merge once checks pass.

### 3d. Approve and Merge

When CI passes, proceed automatically without user confirmation:

```bash
gh pr review NUMBER --repo OWNER/REPO --approve --body "Approved via automated Dependabot review"
```

Then merge using squash (required when running non-interactively):

```bash
gh pr merge NUMBER --repo OWNER/REPO --squash --delete-branch
```

If merge fails (e.g., branch protection, merge conflicts), report the error and ask:
- **Skip** — move to next PR
- **Stop** — end early

After a successful merge, pause briefly before the next PR to let GitHub process the merge (dependabot may rebase remaining PRs).

### 3e. Continue

Move to the next PR and repeat from 3a.

## Step 4: Summary

After all PRs are processed (or user chose "stop"), report:

```
Dependabot PR Review Complete — OWNER/REPO
─────────────────────────────────────────
Merged:       N PRs
Re-triggered: N PRs (checks re-run or branch updated)
Skipped:      N PRs
Failed:       N PRs
Remaining:    N PRs (if stopped early)
```

List the merged PR numbers+titles, any re-triggered (with what action was taken), and any that were skipped or failed with reasons. If PRs were re-triggered, remind the user they can re-invoke the skill in ~15 minutes to merge them once checks pass.

## Common Mistakes

- **Merging without checking CI** — always verify checks pass before offering merge
- **Not handling merge conflicts** — dependabot PRs can conflict with each other; after merging one, later PRs may need rebasing by dependabot
- **Approving PRs in repos you don't have write access to** — `gh pr review --approve` will fail; detect this early
- **Ignoring `--delete-branch`** — always clean up the dependabot branch after merge

## Notes

- Dependabot PRs are authored by `app/dependabot` (not a regular user account)
- After merging one dependabot PR, GitHub may auto-rebase remaining ones — checks on subsequent PRs may temporarily show as pending
- The skill uses `--squash` with `gh pr merge` because `gh` requires an explicit strategy flag when running non-interactively
