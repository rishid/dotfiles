export const meta = {
  name: 'code-review',
  description: 'Multi-agent code review with adversarial verification',
  phases: [
    { title: 'Context', detail: 'Gather diff and project guidelines' },
    { title: 'Review', detail: 'Parallel specialized review agents', model: 'sonnet' },
    { title: 'Verify', detail: 'Adversarial verification of findings', model: 'haiku' },
  ],
}

const FINDING_SCHEMA = {
  type: 'object',
  properties: {
    findings: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          file: { type: 'string' },
          line_start: { type: 'integer' },
          line_end: { type: 'integer' },
          category: {
            type: 'string',
            enum: ['bug', 'security', 'failure-mode', 'edge-case', 'convention', 'test-gap', 'performance', 'simplification'],
          },
          severity: { type: 'string', enum: ['critical', 'high', 'medium', 'low'] },
          title: { type: 'string', description: 'Under 80 chars' },
          description: { type: 'string' },
          evidence: { type: 'string' },
          suggested_fix: { type: 'string', description: 'The EXACT replacement code for those lines only — verbatim, ready to apply. Omit if the fix spans multiple locations or requires structural changes.' },
          fix_is_inline: { type: 'boolean', description: 'true if suggested_fix is a clean line-for-line replacement suitable for a GitHub suggestion block. false if the fix is multi-location or structural.' },
          self_score: { type: 'integer', minimum: 0, maximum: 100 },
        },
        required: ['file', 'line_start', 'line_end', 'category', 'severity', 'title', 'description', 'self_score'],
      },
    },
  },
  required: ['findings'],
}

const VERDICT_SCHEMA = {
  type: 'object',
  properties: {
    refuted: { type: 'boolean' },
    reason: { type: 'string' },
    adjusted_score: { type: 'integer', minimum: 0, maximum: 100 },
  },
  required: ['refuted', 'reason', 'adjusted_score'],
}

const CONTEXT_SCHEMA = {
  type: 'object',
  properties: {
    diffCommand: { type: 'string' },
    diffContent: { type: 'string', description: 'The full diff output' },
    changedFiles: { type: 'array', items: { type: 'string' } },
    diffStat: { type: 'string' },
    claudeMdContent: { type: 'string', description: 'Concatenated content of all CLAUDE.md files found' },
    isIncremental: { type: 'boolean', description: 'true if diff is scoped to changes since last review' },
    lastReviewSha: { type: 'string', description: 'Commit SHA from last review, if found' },
    currentSha: { type: 'string', description: 'Current PR head SHA' },
    previousComments: { type: 'string', description: 'JSON string of inline comments from the last review — path, line, body for each' },
  },
  required: ['diffCommand', 'diffContent', 'changedFiles', 'diffStat'],
}

// --- Parse args (handle string or object) ---

let safeArgs = args || {}
if (typeof safeArgs === 'string') {
  try { safeArgs = JSON.parse(safeArgs) } catch (e) { safeArgs = {} }
}

const scope = safeArgs.scope || 'branch'
const repo = safeArgs.repo || null
const prNumber = safeArgs.prNumber || safeArgs.pr_number || safeArgs.pr || null
const skillDir = safeArgs.skillDir || safeArgs.skill_dir || null

log(`Args — scope: ${scope}, repo: ${repo}, prNumber: ${prNumber}`)

// --- Phase 1: Context agent fetches diff ONCE ---

phase('Context')

let contextPrompt
if (scope === 'incremental' && repo && prNumber) {
  log(`Incremental re-review for PR #${prNumber} on ${repo} — finding last review commit`)
  contextPrompt = `Gather context for an INCREMENTAL re-review of PR #${prNumber} on ${repo}.
Goal: review only what changed since the last review, and check if previously raised issues were addressed.

Step 1 — Find the last review by this user:
  MY_LOGIN=$(gh api user -q .login)
  gh api repos/${repo}/pulls/${prNumber}/reviews \\
    --jq --arg login "$MY_LOGIN" '[.[] | select(.user.login == $login)] | sort_by(.submitted_at) | last | {id: .id, commit_id: .commit_id, submitted_at: .submitted_at}'
  → If result is empty/null: no previous review found, set isIncremental=false and skip to Step 4.
  → Otherwise: note LAST_REVIEW_ID and LAST_REVIEW_SHA (commit_id)

Step 2 — Fetch inline comments from that review:
  gh api repos/${repo}/pulls/${prNumber}/reviews/LAST_REVIEW_ID/comments \\
    --jq '[.[] | {path: .path, line: .line, body: .body, resolved: (.position == null)}]'
  → Return this as previousComments (JSON string). These are the issues previously flagged.

Step 3 — Get current PR head SHA:
  gh pr view ${prNumber} --repo ${repo} --json headRefOid -q .headRefOid
  → CURRENT_SHA

Step 4 — Get the diff:
  If isIncremental=false (no previous review), do a full PR diff:
    gh pr diff ${prNumber} --repo ${repo}
    gh pr view ${prNumber} --repo ${repo} --json additions,deletions,changedFiles \\
      --template '{{.changedFiles}} files changed, {{.additions}} insertions(+), {{.deletions}} deletions(-)'
    Set diffCommand to: gh pr diff ${prNumber} --repo ${repo}

  If isIncremental=true and LAST_REVIEW_SHA != CURRENT_SHA, get only changes since last review:
    gh api repos/${repo}/compare/LAST_REVIEW_SHA...CURRENT_SHA \\
      --jq '[.files[] | {filename: .filename, patch: .patch, additions: .additions, deletions: .deletions}]'
    Build diffContent: for each file → "diff --git a/{filename} b/{filename}\\n{patch}\\n"
    Build changedFiles from filenames (skip files with null patch — binary files).
    Build diffStat: count total additions/deletions across files.
    Set diffCommand to: gh api repos/${repo}/compare/LAST_REVIEW_SHA...CURRENT_SHA

  If LAST_REVIEW_SHA == CURRENT_SHA: no new commits since last review. Return changedFiles=[] and diffContent="".

Step 5 — Find CLAUDE.md files:
  find . -name 'CLAUDE.md' -maxdepth 3 -not -path '*/node_modules/*' 2>/dev/null
  → concatenate contents into claudeMdContent

Return: diffCommand, diffContent, changedFiles (array), diffStat, claudeMdContent, isIncremental, lastReviewSha, currentSha, previousComments.
IMPORTANT: diffContent must be complete. Do not truncate.`

} else if (scope === 'pr' && repo && prNumber) {
  log(`Fetching diff for PR #${prNumber} on ${repo}`)
  contextPrompt = `Gather ALL context for reviewing GitHub PR #${prNumber} on ${repo}.

Run these commands:

1. gh pr diff ${prNumber} --repo ${repo} --name-only
   → return as changedFiles array

2. gh pr diff ${prNumber} --repo ${repo}
   → return the FULL output as diffContent (this is critical — other agents need this)
   → also set diffCommand to: gh pr diff ${prNumber} --repo ${repo}

3. gh pr view ${prNumber} --repo ${repo} --json additions,deletions,changedFiles --template '{{.changedFiles}} files changed, {{.additions}} insertions(+), {{.deletions}} deletions(-)'
   → return as diffStat

4. find . -name 'CLAUDE.md' -maxdepth 3 -not -path '*/node_modules/*' 2>/dev/null
   → if any found, read them and concatenate into claudeMdContent. If none, set to empty string.

IMPORTANT: diffContent must contain the complete diff output. Do not truncate it.`
} else {
  log(`Fetching diff for local ${scope} review`)
  contextPrompt = `Gather ALL context for a local code review. Scope: ${scope}

1. Detect base branch:
   git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main"

2. Based on scope "${scope}":
   - "branch": diffCommand = "git diff origin/<base>...HEAD"
   - "staged": diffCommand = "git diff --staged"
   - "commit": diffCommand = "git show HEAD"

3. Run the diffCommand → return FULL output as diffContent
4. Run diffCommand with --name-only → return as changedFiles array
5. Run diffCommand with --stat → return as diffStat

6. find . -name 'CLAUDE.md' -maxdepth 3 -not -path '*/node_modules/*' 2>/dev/null
   → if any found, read them and concatenate into claudeMdContent. If none, empty string.

IMPORTANT: diffContent must contain the complete diff output. Do not truncate it.`
}

const ctx = await agent(contextPrompt, {
  label: 'gather-context', model: 'haiku', schema: CONTEXT_SCHEMA,
})

if (!ctx || !ctx.changedFiles || ctx.changedFiles.length === 0) {
  log('No changed files found — nothing to review')
  return { confirmed: [], stats: { total: 0, confirmed: 0, agentCount: 0 } }
}

const diffCommand = ctx.diffCommand
const diffContent = ctx.diffContent || ''
const changedFiles = ctx.changedFiles
const diffStat = ctx.diffStat || ''
const claudeMdContent = ctx.claudeMdContent || ''
const isIncremental = ctx.isIncremental || false
const lastReviewSha = ctx.lastReviewSha || null
const currentSha = ctx.currentSha || null
const previousComments = ctx.previousComments || null

if (isIncremental && lastReviewSha) {
  log(`Incremental review: changes from ${lastReviewSha.substring(0, 8)} → ${(currentSha || 'HEAD').substring(0, 8)} (${changedFiles.length} files)`)
} else if (isIncremental) {
  log(`No previous review found — falling back to full PR diff`)
} else {
  log(`Full review: ${changedFiles.length} files, diff is ${diffContent.length} chars`)
}

// --- Detect languages ---

const langMap = {
  '.py': 'python', '.go': 'go', '.c': 'c', '.h': 'c',
  '.cpp': 'cpp', '.cc': 'cpp', '.cxx': 'cpp', '.hpp': 'cpp',
  '.ts': 'typescript', '.tsx': 'typescript', '.js': 'typescript', '.jsx': 'typescript',
  '.rs': 'rust', '.rb': 'ruby', '.java': 'java', '.kt': 'kotlin',
  '.cs': 'csharp', '.swift': 'swift', '.php': 'php', '.dart': 'dart',
}

const detectedLangs = [...new Set(
  changedFiles.map(f => {
    const dot = f.lastIndexOf('.')
    if (dot === -1) return null
    return langMap[f.substring(dot)]
  }).filter(Boolean)
)]

// --- Build shared prompt parts (diff is INLINE, not fetched per agent) ---

const rulesInstruction = skillDir ? [
  'Read these rule files for review checklists:',
  `- ${skillDir}/rules/universal.md`,
  ...detectedLangs.map(l => `- ${skillDir}/rules/${l}.md (if exists)`),
].join('\n') : ''

const guidelinesSection = claudeMdContent
  ? `\n\n## Project Guidelines (from CLAUDE.md)\n\n${claudeMdContent}`
  : ''

const falsePositiveGuidance = `
DO NOT flag: pre-existing issues, linter/type issues, issues on unmodified lines, pure style nitpicks, intentional behavior.
DO flag even if minor: missing error handling, edge case gaps, null access without guards, resource leaks, test gaps, security vulns.`

const previousCommentsSection = (isIncremental && previousComments)
  ? `\n\n## Issues Raised in Last Review\n\nThese are the inline comments posted during the last review:\n\n\`\`\`json\n${previousComments}\n\`\`\`\n\nFor unresolved previous comments: only re-surface as a finding if the issue is clearly critical or high severity (a real bug, security issue, or data integrity risk). Do NOT re-flag unresolved low-severity, style, or convention issues — the contributor has seen them and they are their call to address.`
  : ''

const reviewScope = isIncremental && lastReviewSha
  ? `INCREMENTAL RE-REVIEW: This diff shows ONLY changes made since the last review (commit ${lastReviewSha.substring(0, 8)}). Focus on: (1) new issues in the changed code, (2) whether previously raised issues (listed above) are resolved.`
  : `FULL PR REVIEW: This diff shows all changes in the PR.`

// The diff is embedded directly — agents do NOT run git/gh commands to get it
const buildPrompt = (role, focus) => `${role}
${rulesInstruction}${guidelinesSection}${previousCommentsSection}

## Diff Under Review

${reviewScope}

Changed files: ${changedFiles.join(', ')}
Stats: ${diffStat}

\`\`\`diff
${diffContent}
\`\`\`

${focus}
${falsePositiveGuidance}

IMPORTANT TOKEN EFFICIENCY RULES:
- The diff above contains ALL the changes. Do NOT re-fetch it with git or gh commands.
- Do NOT read full file contents unless you need surrounding context to confirm a specific bug.
- Limit file reads to at most 5 files, only when the diff alone is ambiguous.
- Return at most 7 findings, prioritized by severity. Quality over quantity.

For suggested_fix: provide the EXACT replacement lines of code, not a description. It will be applied verbatim via GitHub's suggestion feature. Set fix_is_inline=true only if it's a clean replacement for those specific lines. If the fix requires changes elsewhere or is structural, omit suggested_fix or set fix_is_inline=false.

Score each finding 0-100 on confidence it is a real NEW issue in this diff.`

// --- Scale agents: 3 base, +1 at 10 files, +1 at 20 files (max 5) ---

const fileCount = changedFiles.length
const agentConfig = []

// Always: combined bug + failure mode scanner
agentConfig.push({
  label: 'bugs-and-failures',
  effort: 'high',
  prompt: buildPrompt(
    'You are a bug hunter and failure mode analyst.',
    `Scan the diff for bugs at multiple depths:

**Surface**: Typos, wrong variable names, missing returns, copy-paste errors.
**Logic**: Trace conditionals/loops with concrete inputs. For each branch, what input takes that path?
**Failure modes**: For each operation — what if it fails? Null returns, exceptions, unhandled rejections, timeouts.
**Edge cases**: Empty inputs, boundary values, malformed data, zero/negative values.
**Cross-function**: If a changed function calls another changed function, verify the contract is honored.
**Guard correctness**: Does each conditional handle the actual type space? (null, 0, "", arrays, etc.)
**Incomplete coverage**: For switch/if-else chains, are all runtime inputs handled?

Only read a source file if the diff alone is genuinely ambiguous about a specific bug. Most issues are visible from the diff.`
  ),
})

// Always: security
agentConfig.push({
  label: 'security',
  prompt: buildPrompt(
    'You are a security specialist.',
    `Check for:
- **Injection**: SQL, command, XSS, template injection via string interpolation
- **Auth/Authz**: Missing checks, privilege escalation, insecure sessions
- **Secrets**: Hardcoded credentials, API keys, tokens
- **Input validation**: Missing validation at trust boundaries
- **Data exposure**: Error messages leaking internals, PII in logs
- **Unsafe ops**: Deserialization of untrusted data, path traversal`
  ),
})

// Always: conventions + simplification + tests (combined to save an agent)
agentConfig.push({
  label: 'quality-and-tests',
  prompt: buildPrompt(
    'You are a code quality, test coverage, and simplification reviewer.',
    `**Conventions**: Check compliance with project guidelines above (if any). Flag only explicit violations.

**Test coverage**:
- New code paths: Is there a corresponding test?
- Error paths tested? Edge cases?
- Critical paths (auth, data integrity): proportionate coverage?

**Simplification**:
- Could this be simpler? Premature abstractions? Helpers used once?
- Over-configured solutions for simple problems?
- Could existing patterns/libraries handle this?`
  ),
})

// 10+ files: add context/patterns agent
if (fileCount >= 10) {
  agentConfig.push({
    label: 'context-and-patterns',
    prompt: buildPrompt(
      'You are a historical context and pattern analyst.',
      `Check if changes break established patterns or contradict existing code.
Run git blame on at most 3 key modified files (the most complex ones) to understand why code was written that way.
Check at most 2 sibling files for pattern consistency.
Flag only issues where historical context reveals a real problem.

Limit yourself to at most 10 tool calls total.`
    ),
  })
}

// 20+ files: add performance + deployment agent
if (fileCount >= 20) {
  agentConfig.push({
    label: 'perf-and-deploy',
    prompt: buildPrompt(
      'You are a performance and deployment safety reviewer.',
      `**Performance**: N+1 queries, blocking I/O in async, unnecessary recomputations, memory leaks, missing pagination.
**Breaking changes**: Public API modifications? Consumer-breaking type changes?
**Deployment**: Migration risks? Backwards compatibility? Rollback safety? Observability gaps?`
    ),
  })
}

// --- Phase 2: Review ---

phase('Review')
log(`Launching ${agentConfig.length} review agents for ${fileCount} files`)

const reviews = await parallel(
  agentConfig.map(a => () =>
    agent(a.prompt, {
      label: a.label,
      phase: 'Review',
      model: 'sonnet',
      effort: a.effort,
      schema: FINDING_SCHEMA,
    })
  )
)

const allFindings = reviews.filter(Boolean).flatMap(r => r.findings)
log(`Found ${allFindings.length} raw findings across ${agentConfig.length} agents`)

if (allFindings.length === 0) {
  return { confirmed: [], stats: { total: 0, confirmed: 0, agentCount: agentConfig.length } }
}

// --- Dedup ---

const deduped = []
for (const f of allFindings) {
  const overlap = deduped.find(d =>
    d.file === f.file &&
    d.category === f.category &&
    Math.abs(d.line_start - f.line_start) <= 5
  )
  if (overlap) {
    overlap.self_score = Math.min(100, Math.max(overlap.self_score, f.self_score) + 10)
    if (f.evidence && (!overlap.evidence || f.evidence.length > overlap.evidence.length)) overlap.evidence = f.evidence
    if (f.suggested_fix && (!overlap.suggested_fix || f.suggested_fix.length > overlap.suggested_fix.length)) overlap.suggested_fix = f.suggested_fix
  } else {
    deduped.push({ ...f })
  }
}

log(`${deduped.length} unique findings after dedup`)

// Filter + cap: raise threshold and limit verifier count
const MAX_VERIFIERS = 15
const allWorthVerifying = deduped
  .filter(f => f.self_score >= 55)
  .sort((a, b) => {
    const sev = { critical: 0, high: 1, medium: 2, low: 3 }
    return (sev[a.severity] - sev[b.severity]) || (b.self_score - a.self_score)
  })
const worthVerifying = allWorthVerifying.slice(0, MAX_VERIFIERS)
if (allWorthVerifying.length > MAX_VERIFIERS) {
  log(`${allWorthVerifying.length} findings above threshold, capping verification at ${MAX_VERIFIERS} (top by severity)`)
}
log(`${worthVerifying.length} findings to verify`)

if (worthVerifying.length === 0) {
  return { confirmed: [], stats: { total: allFindings.length, confirmed: 0, agentCount: agentConfig.length } }
}

// --- Phase 3: Adversarial Verification ---
// Verifiers get the diff excerpt INLINE and must NOT use tools (no file reads, no git commands).
// This keeps each verifier under ~5k tokens instead of 30-45k.

phase('Verify')
log(`Launching ${worthVerifying.length} adversarial verifiers (tool-free, diff inline)`)

const verifications = await parallel(
  worthVerifying.map(f => {
    const fileHunks = diffContent.split(/^diff --git /m)
      .filter(h => h.includes(f.file))
      .join('\n')
      .substring(0, 4000)

    return () => agent(
      `You are an adversarial verifier. Your ONLY job is to decide if this finding is real or a false positive.

DO NOT read files. DO NOT run any commands. All the information you need is below.

**Finding:** ${f.title}
- File: ${f.file}, Line: ${f.line_start}-${f.line_end}
- Category: ${f.category}, Severity: ${f.severity}
- Description: ${f.description}
${f.evidence ? '- Evidence: ' + f.evidence : ''}

**Diff for this file:**
\`\`\`diff
${fileHunks}
\`\`\`

Based ONLY on the diff above, try to refute:
- Is the code actually correct? Is this a false positive?
- Does the diff context show this is intentional?
- Would the language/runtime prevent this?
- Is this a style preference, not a correctness issue?
- Could this be pre-existing (not introduced in the + lines)?

Default to refuted=true if the diff doesn't clearly confirm the issue.
Score 0-100. Below 70 = refuted.`,
      {
        label: `verify:${f.file}:${f.line_start}`,
        phase: 'Verify',
        model: 'haiku',
        schema: VERDICT_SCHEMA,
      }
    )
  })
)

const confirmed = worthVerifying
  .map((f, i) => {
    const v = verifications[i]
    if (!v || v.refuted || v.adjusted_score < 70) return null
    return { ...f, verified_score: v.adjusted_score, verification_note: v.reason }
  })
  .filter(Boolean)
  .sort((a, b) => {
    const sev = { critical: 0, high: 1, medium: 2, low: 3 }
    return (sev[a.severity] - sev[b.severity]) || (b.verified_score - a.verified_score)
  })

log(`${confirmed.length} findings confirmed (${worthVerifying.length - confirmed.length} refuted)`)

return {
  confirmed,
  isIncremental,
  lastReviewSha,
  currentSha,
  previousComments,
  stats: {
    total: allFindings.length,
    confirmed: confirmed.length,
    agentCount: agentConfig.length,
  },
}
