---
name: dependabot-pr-merge
description: Find open Dependabot PRs for a GitHub repo, review CI status, and approve+merge them one at a time.
user-invocable: true
argument-hint: "OWNER/REPO or GitHub URL (omit to infer from current repo)"
allowed-tools: Bash, AskUserQuestion, Agent
---

# Dependabot PR Merge

Review and merge open Dependabot PRs for a GitHub repository. Checks CI on all PRs first, then batch-merges all passing ones (single confirmation), and handles failing/pending ones individually.

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

## Step 3: Check CI Status for All PRs

Before merging anything, check CI on **every** open PR. This is pure mechanical data-gathering (run a command per PR, bucket the result — no judgment calls), so delegate it to a Haiku subagent instead of doing it inline:

Invoke the `Agent` tool once with `model: "haiku"` and a prompt listing every open PR number and OWNER/REPO. Instruct it to:
1. Run `gh pr checks NUMBER --repo OWNER/REPO` for each PR number given.
2. Categorize each PR into one of three buckets:

| Bucket | Criteria |
|--------|----------|
| **passing** | All checks pass, or no checks configured |
| **pending** | Some checks are still running |
| **failed** | One or more checks failed |

3. Return the buckets as plain lists of PR numbers (e.g. `passing: [121, 123, 125]`, `pending: [124]`, `failed: [122]`), nothing else.

Use the returned buckets directly — don't re-run the checks yourself. If a PR count is very small (1-2 PRs), it's fine to just run the checks inline instead of spawning a subagent for it.

After checking all PRs, display a triage summary:

```
CI Triage — OWNER/REPO
──────────────────────
Passing (ready to merge): #121, #123, #125
Pending (still running):  #124
Failed:                   #122
```

## Step 4: Batch Merge All Passing PRs

**If there are 2 or more passing PRs**, ask once using `AskUserQuestion`:
- **Merge all N passing PRs** — approve and merge every passing PR sequentially without further prompts
- **Review one at a time** — skip batch mode; handle each PR individually (proceed to Step 5)
- **Stop** — end the skill, show summary

**If there is exactly 1 passing PR**, skip the batch prompt and merge it automatically (no confirmation needed).

**If there are 0 passing PRs**, skip to Step 5.

### Batch merge execution

Build a single chained Bash command covering all passing PRs (oldest first) and execute it in one shot:

```bash
gh pr review 121 --repo OWNER/REPO --approve --body "Approved via automated Dependabot review" && \
gh pr merge 121 --repo OWNER/REPO --squash --delete-branch && \
gh pr review 123 --repo OWNER/REPO --approve --body "Approved via automated Dependabot review" && \
gh pr merge 123 --repo OWNER/REPO --squash --delete-branch && \
gh pr review 125 --repo OWNER/REPO --approve --body "Approved via automated Dependabot review" && \
gh pr merge 125 --repo OWNER/REPO --squash --delete-branch
```

The `&&` chain stops on the first failure, which is desirable — a failed merge on PR N prevents accidentally merging PR N+1 on a potentially broken base. If the command stops early, report which PR failed, add it to the "failed" bucket, and move on to Step 5 for the non-passing PRs.

## Step 5: Handle Non-Passing PRs Individually

For each PR in the **pending** or **failed** buckets, in order:

Show the PR (number, title, which checks are pending/failed), then use `AskUserQuestion` with:
- **Re-run failed checks** — re-run only the failed/pending workflow runs without changing the branch (good for flaky tests)
- **Update branch & re-run** — rebase the PR onto the latest base branch, triggering a full fresh CI run (good when the base branch has fixes)
- **Skip** — move to the next PR
- **Stop** — end the skill, show summary

#### Re-run failed checks

```bash
# Get the head SHA
HEAD_SHA=$(gh pr view NUMBER --repo OWNER/REPO --json headRefOid --jq '.headRefOid')

# List failed/pending check run IDs
gh api "repos/OWNER/REPO/commits/${HEAD_SHA}/check-runs" \
  --jq '.check_runs[] | select(.conclusion == "failure" or .conclusion == null) | .id'

# Re-run the associated workflow runs
gh run rerun RUN_ID --repo OWNER/REPO --failed
```

After triggering, report what was re-triggered and move to the next PR.

#### Update branch & re-run

```bash
gh api -X PUT "repos/OWNER/REPO/pulls/NUMBER/update-branch" \
  -f update_method="rebase"
```

This rebases the PR onto the latest base, triggering a full CI run. After triggering, report and move to the next PR.

The user can re-invoke the skill later to merge PRs whose checks now pass.

## Step 6: Summary

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

List merged PR numbers+titles, re-triggered PRs with the action taken, and skipped/failed PRs with reasons. If PRs were re-triggered, remind the user they can re-invoke the skill in ~15 minutes to merge them.

## Common Mistakes

- **Merging without checking CI** — always verify checks pass before merging
- **Not handling merge conflicts** — dependabot PRs can conflict with each other; after merging one, later PRs may need rebasing by dependabot
- **Approving PRs in repos you don't have write access to** — `gh pr review --approve` will fail; detect this early
- **Ignoring `--delete-branch`** — always clean up the dependabot branch after merge

## Notes

- Dependabot PRs are authored by `app/dependabot` (not a regular user account)
- GitHub has no batch merge API — PRs must be merged one at a time, but a single upfront confirmation covers all passing PRs
- After merging one dependabot PR, GitHub may auto-rebase remaining ones — checks on subsequent PRs may temporarily show as pending
- The skill uses `--squash` with `gh pr merge` because `gh` requires an explicit strategy flag when running non-interactively
