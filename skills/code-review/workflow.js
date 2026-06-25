export const meta = {
  name: 'code-review',
  description: 'Multi-agent code review with adversarial verification',
  phases: [
    { title: 'Context', detail: 'Gather diff and project guidelines' },
    { title: 'Review', detail: 'Parallel specialized + holistic review agents', model: 'sonnet' },
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
            enum: ['bug', 'security', 'failure-mode', 'edge-case', 'convention', 'test-gap', 'performance', 'simplification', 'removed-behavior', 'bandaid'],
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

// --- Detect if diff has deletions worth auditing ---

const hasSignificantDeletions = (diffContent.match(/^-[^-]/gm) || []).length > 5

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
## What NOT to flag (false positives erode trust)
- Pre-existing issues not introduced in this diff
- Issues on unmodified lines (context lines without + prefix)
- Pure style/formatting nitpicks unless CLAUDE.md explicitly requires them
- Issues a linter or type checker would catch
- Intentional behavior evident from comments or context
- Code that "could be better" but isn't wrong
- Potential issues that depend on specific inputs or runtime state you cannot verify from the diff`

const previousCommentsSection = (isIncremental && previousComments)
  ? `\n\n## Issues Raised in Last Review\n\nThese are the inline comments posted during the last review:\n\n\`\`\`json\n${previousComments}\n\`\`\`\n\nFor unresolved previous comments: only re-surface as a finding if the issue is clearly critical or high severity (a real bug, security issue, or data integrity risk). Do NOT re-flag unresolved low-severity, style, or convention issues — the contributor has seen them and they are their call to address.`
  : ''

const reviewScope = isIncremental && lastReviewSha
  ? `INCREMENTAL RE-REVIEW: This diff shows ONLY changes made since the last review (commit ${lastReviewSha.substring(0, 8)}). Focus on: (1) new issues in the changed code, (2) whether previously raised issues (listed above) are resolved.`
  : `FULL PR REVIEW: This diff shows all changes in the PR.`

const tokenRules = `
IMPORTANT TOKEN EFFICIENCY RULES:
- The diff above contains ALL the changes. Do NOT re-fetch it with git or gh commands.
- Do NOT read full file contents unless you need surrounding context to confirm a specific bug.
- Limit file reads to at most 5 files, only when the diff alone is ambiguous.
- Return at most 7 findings, prioritized by severity. Quality over quantity.`

const fixInstructions = `
For suggested_fix: provide the EXACT replacement lines of code, not a description. It will be applied verbatim via GitHub's suggestion feature. Set fix_is_inline=true only if it's a clean replacement for those specific lines. If the fix requires changes elsewhere or is structural, omit suggested_fix or set fix_is_inline=false.

Score each finding 0-100 on confidence it is a real NEW issue in this diff.`

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
${tokenRules}
${fixInstructions}`

// --- Agent config: 3 base + conditional agents ---

const fileCount = changedFiles.length
const agentConfig = []

// --- Agent 1: Bug hunter + silent failure auditor (always) ---
agentConfig.push({
  label: 'bugs-and-failures',
  effort: 'high',
  prompt: buildPrompt(
    'You are a bug hunter and error handling auditor. You have zero tolerance for code that will produce wrong results or silently swallow errors.',
    `Scan the diff for bugs at multiple depths and audit every error handling path:

**Surface bugs**: Typos, wrong variable names, missing returns, copy-paste errors, off-by-one.
**Logic bugs**: Trace conditionals and loops with concrete inputs. For each branch, what input takes that path? Would it produce the right result?
**Guard correctness**: Does each conditional handle the actual type space? (null, 0, "", empty arrays, etc.)
**Incomplete coverage**: For switch/if-else chains, are all runtime inputs handled? Missing default/else?

**Exception/error handling audit** — for every error handling site in the diff:
- Empty catch/except blocks are critical defects, no exceptions.
- Catch blocks that only log and continue: is the error truly recoverable, or is this hiding a problem?
- **Broad exception catching with mismatched handlers**: Does \`except Exception\` / \`catch (Exception e)\` dispatch to a handler that expects a specific exception subtype? (e.g., handler accesses \`.detail\` which only exists on HTTPException, not on all Exceptions). List the unexpected error types this could swallow and crash on.
- Fallback/default values on failure without logging: is the caller aware the fallback happened?
- Optional chaining (\`?.\`) or null coalescing (\`??\`) that silently skips operations that should not be skippable.

**Framework/library integration bugs** — when code replaces or wraps framework components:
- Does new middleware/decorator logic preserve framework behaviors (header injection, hooks, decorators)?
- When calling framework internals with non-standard arguments (e.g., \`endpoint=None\`, \`handler=None\`), does this bypass features that should run?
- Are private API imports (leading underscore) used? These have no stability guarantee and may break.
- When old code is replaced, list the behaviors the old code had that the new code might be missing.

**Cross-function contracts**: If a changed function calls or is called by another changed function, verify the contract (types, nullability, error propagation) is honored in both directions.

Only read a source file if the diff alone is genuinely ambiguous about a specific bug. Most issues are visible from the diff.`
  ),
})

// --- Agent 2: Security (always) ---
agentConfig.push({
  label: 'security',
  prompt: buildPrompt(
    'You are a security specialist focused exclusively on vulnerabilities introduced in this diff.',
    `Check for:
- **Injection**: SQL, command, XSS, template injection via string interpolation — require parameterized queries or safe APIs
- **Auth/Authz**: Missing checks, privilege escalation, insecure sessions, token handling
- **Secrets**: Hardcoded credentials, API keys, tokens, connection strings — require env vars or secrets manager
- **Input validation**: Missing validation at trust boundaries (user input, external APIs, deserialized data)
- **Data exposure**: Error messages leaking internals, PII in logs, overly verbose debug output
- **Unsafe ops**: Deserialization of untrusted data, path traversal, SSRF, open redirects
- **Crypto**: Weak algorithms, hardcoded IVs/salts, custom crypto instead of standard libraries`
  ),
})

// --- Agent 3: Removed behavior + cross-file impact (always) ---
agentConfig.push({
  label: 'impact-analysis',
  prompt: buildPrompt(
    'You are a change impact analyst. You trace the blast radius of modifications — what was removed, what was changed, and who depends on it.',
    `Three focus areas:

**Removed behavior audit** — examine every deleted line (lines starting with \`-\`) in the diff:
- Was a function, method, class, endpoint, config key, or export removed or renamed?
- Was a default value, fallback, or error handler removed?
- Was a validation check, guard clause, or security check removed?
- For each removal: is there a replacement in the \`+\` lines, or was it dropped entirely?
- If dropped: could any caller, config, test, or downstream system still depend on it?

**Replacement completeness** — when middleware, decorators, or framework components are replaced:
- List the behaviors/features the OLD component provided (check its docs or source if available in context).
- Verify each behavior is present in the NEW implementation.
- Examples: header injection, hook execution, decorator processing, error handling paths.
- If the old component called framework features (e.g., \`_find_route_handler\`, \`_inject_headers\`), does the new code still call them OR intentionally skip them? If skipped, is there a comment explaining why?

**Cross-file caller/callee impact** — for each function/method whose signature, return type, error behavior, or side effects changed:
- Read at most 3 key callers (use grep to find them, then read only the relevant section) to verify they handle the new contract.
- Check: does the caller handle new error types? Does it expect the old return shape? Does it pass arguments the new signature still accepts?
- Flag if a changed function is exported/public and callers outside the diff may break.

${hasSignificantDeletions ? 'This diff has significant deletions — be thorough on the removed-behavior audit.' : 'This diff has few deletions — focus more on cross-file impact.'}

Limit yourself to at most 10 tool calls total (grep + targeted file reads).`
  ),
})

// --- Agent 4: CLAUDE.md compliance (only when CLAUDE.md exists) ---
if (claudeMdContent) {
  agentConfig.push({
    label: 'guidelines-compliance',
    prompt: buildPrompt(
      'You are a project guidelines compliance auditor. You verify that code changes follow the explicit rules in the project\'s CLAUDE.md files.',
      `Your ONLY job is to check the diff against the Project Guidelines above.

For each rule in the CLAUDE.md:
- Is it relevant to the files changed? (Only apply rules to files in matching directories.)
- Does the new code (+lines) violate it?
- Quote the exact rule being violated and the exact code that breaks it.

DO NOT flag:
- Rules that are guidance for AI assistants rather than code requirements
- Violations on unchanged/context lines (only \`-\` prefix or no prefix)
- Style preferences not explicitly stated as rules
- Issues already silenced by lint-ignore comments or equivalent

Only flag issues where you can cite BOTH the exact CLAUDE.md rule AND the exact violating code. If you cannot quote both, do not flag it.`
    ),
  })
}

// --- Agent 5: Holistic reader (always) — finds what checklists miss ---
// Deliberately minimal prescription. Reads the diff as a whole, reasons about
// what the code does, what changed, and what could go wrong. Catches novel
// patterns that don't map to any specific checklist item.
agentConfig.push({
  label: 'holistic-reader',
  effort: 'high',
  prompt: buildPrompt(
    'You are a senior engineer doing a deep holistic code review. You have no checklist. You read code and think.',
    `Read the entire diff carefully and find real problems.

Your job is NOT to pattern-match against a list of known issues. It is to understand what this code does and reason about what could go wrong.

Ask yourself:
- What is this change trying to do? Is it achieving that goal correctly?
- If I were the on-call engineer at 3am when this breaks, what scenario would page me?
- What assumptions does this code make that could be wrong in production?
- What was the old code doing that the new code no longer does?
- Are there conditions under which this code produces incorrect results, crashes, or silently misbehaves?
- Does the code's description (comments, PR description) match what it actually does?
- Are there behaviors that exist in the old code that are simply missing from the new code?

Go deep on a few real issues. Do not surface style or preference nitpicks.
Prioritize: correctness > reliability > security > maintainability.`
  ),
})

// --- Agent 6: Quality, tests, altitude check (always when test files changed, else 10+ files) ---
const hasTestFiles = changedFiles.some(f => f.includes('test') || f.includes('spec'))
if (fileCount >= 10 || hasTestFiles) {
  agentConfig.push({
    label: 'quality-tests-altitude',
    prompt: buildPrompt(
      'You are a code quality, test coverage, and design altitude reviewer.',
      `Three focus areas:

**Test coverage** — for new/changed code paths:
- Is there a corresponding test? If not, is this a critical path (auth, data integrity, financial) that MUST have one?
- Are error/exception paths tested?
- Are edge cases (empty input, boundary values, concurrent access) covered?
- Do tests verify behavior and contracts, not implementation details?

**Simplification** — look for unnecessary complexity:
- Premature abstractions (helpers/wrappers used exactly once)?
- Over-engineered solutions for simple problems?
- Could existing project patterns or standard library features replace custom code?
- Redundant code introduced across multiple files that could share a single implementation?

**Altitude check** — is this the right fix at the right level?
- Does this change fix the symptom but not the root cause? (e.g., adding a null check instead of fixing why the value is null)
- Does it add a workaround that will need to be cleaned up later?
- Is there a string/regex/manual approach where a proper parser, schema, or type would be more robust?
- Is a retry/timeout being added to paper over an architectural issue?

Be constructive — only flag altitude issues when there is a clearly better alternative, not just because the approach is "not ideal".`
    ),
  })
}

// --- Agent 7: Performance + deployment (20+ files) ---
if (fileCount >= 20) {
  agentConfig.push({
    label: 'perf-and-deploy',
    prompt: buildPrompt(
      'You are a performance and deployment safety reviewer.',
      `**Performance**: N+1 queries, blocking I/O in async contexts, unnecessary recomputations, memory leaks (event listeners, closures, growing collections), missing pagination on unbounded queries.
**Breaking changes**: Public API modifications? Changed response shapes? Removed exports? Consumer-breaking type changes?
**Deployment**: Migration risks? Backwards compatibility with existing data? Rollback safety? Feature flags needed?`
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

// Filter + cap: lower threshold to 50 (was 55) to pass more borderline findings to verifier
const SELF_SCORE_THRESHOLD = 50
const MAX_VERIFIERS = 20
const dropped = deduped.filter(f => f.self_score < SELF_SCORE_THRESHOLD)
if (dropped.length > 0) {
  log(`Dropped ${dropped.length} findings below score ${SELF_SCORE_THRESHOLD}: ${dropped.map(f => `[${f.severity}] ${f.title} (${f.self_score})`).join(' | ')}`)
}
const allWorthVerifying = deduped
  .filter(f => f.self_score >= SELF_SCORE_THRESHOLD)
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

Based ONLY on the diff above, answer these questions:

**To refute (finding is wrong):**
- Is the code actually correct — can you trace through it and show it works?
- Does the diff context or a comment show this is explicitly intentional?
- Would the language/runtime prevent this issue from occurring?
- Is this pre-existing, not introduced in the + lines?
- For removed-behavior findings: is there a replacement in the + lines the reviewer missed?
- For impact-analysis findings: does the diff show callers being updated?

**To confirm (finding is real):**
- For exception-handling: trace ALL error types that can reach the handler. If the handler accesses a subclass attribute (e.g., .detail, .status_code), can a non-subclass exception reach it?
- For framework-integration: does the new code preserve the old code's behaviors (header injection, decorator processing, exemption checks)? If a behavior is missing, is there an explicit comment explaining why?
- For latent bugs: does the issue exist even if the bad path is rarely triggered?

**Scoring guidance by category:**
- bug / failure-mode / security: Confirm unless you can PROVE the code is correct. Uncertainty defaults to confirmed.
- removed-behavior / test-gap: Confirm if the behavior/test is clearly missing.
- convention / simplification: Confirm only if clearly supported by diff evidence.
- Do NOT refute just because "it probably works" or "it's unlikely to happen" — latent bugs are real bugs.

Score 0–100. Below 65 = refuted.`,
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
    if (!v || v.refuted || v.adjusted_score < 65) return null
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
