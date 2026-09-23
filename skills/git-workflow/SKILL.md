---
name: git-workflow
description: Use when asked to commit changes or open a pull request. Keep commit-only and PR workflows distinct.
---

# Git workflow

Follow explicit user instructions and repository policy ahead of these guidelines. Inspect the current branch, status, remotes, and relevant `AGENTS.md`, `CLAUDE.md`, contributing notes, or branch rules before mutating Git state. Review the intended diff and stage only related files; preserve unrelated work. Use a clear commit message that describes the change.

## Commit only

For “commit this” or equivalent, commit the intended changes on the current branch. Do not pull, create a branch, push, or open a PR merely because a commit was requested. Some repositories allow direct commits to `main` or `master`; others require a branch and review. Follow a known repository rule over the default. If committing on the current branch would violate that rule, move the intended work to a permitted branch and use the required review path. Ask only when a material policy or scope question cannot be resolved from the repository or user request.

## Open a PR

Use this path when the user asks to open a PR or a known repository rule requires PR review for the intended change. Identify the target branch from the request and repository; use `master` when that is the required target, rather than assuming every repository uses it. Fetch the target branch, ensure its latest remote tip is known, and create the feature branch from that tip. If local `master` must be updated, fast-forward it when safe; do not merge unrelated local commits into the new branch. Move only the intended work onto the new branch using a safe approach for its current state, such as cherry-pick, patch, or stash. Verify the branch base and resulting diff before committing. Keep existing work intact if a conflict needs resolution.

Run checks relevant to the change. Push the feature branch and open a PR when authorized by the user's request or required repository workflow. Write the PR title and description for a reviewer unfamiliar with the conversation: state the problem and resulting behavior, include relevant validation, and disclose material limitations. Do not use a generic template or claim checks that did not run. Return the PR link and any important unresolved issue.

Never force-push or bypass failing hooks without explicit authorization. Do not change Git configuration as part of this workflow.
