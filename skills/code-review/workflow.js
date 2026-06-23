export const meta = {
  name: 'code-review',
  description: 'Multi-agent code review with adversarial verification',
  phases: [
    { title: 'Context', detail: 'Gather diff, changed files, project guidelines' },
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
          file: { type: 'string', description: 'File path relative to repo root' },
          line_start: { type: 'integer', description: 'Starting line number' },
          line_end: { type: 'integer', description: 'Ending line number (same as start if single line)' },
          category: {
            type: 'string',
            enum: ['bug', 'security', 'failure-mode', 'edge-case', 'convention', 'test-gap', 'performance', 'simplification'],
          },
          severity: { type: 'string', enum: ['critical', 'high', 'medium', 'low'] },
          title: { type: 'string', description: 'Brief description of the issue (under 80 chars)' },
          description: { type: 'string', description: 'Detailed explanation of the issue and why it matters' },
          evidence: { type: 'string', description: 'Code snippet or command output that proves this issue' },
          suggested_fix: { type: 'string', description: 'Concrete code or approach to fix the issue' },
          self_score: {
            type: 'integer', minimum: 0, maximum: 100,
            description: 'Confidence 0-100 that this is a real NEW issue introduced in this diff',
          },
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
    refuted: { type: 'boolean', description: 'true if the finding is a false positive' },
    reason: { type: 'string', description: 'Why the finding was confirmed or refuted' },
    adjusted_score: {
      type: 'integer', minimum: 0, maximum: 100,
      description: 'Adjusted confidence after verification. 0-25: false positive. 26-50: uncertain. 51-75: likely real. 76-100: confirmed real.',
    },
  },
  required: ['refuted', 'reason', 'adjusted_score'],
}

const CONTEXT_SCHEMA = {
  type: 'object',
  properties: {
    diffCommand: { type: 'string', description: 'The exact command to run to see the diff' },
    changedFiles: { type: 'array', items: { type: 'string' }, description: 'Array of changed file paths' },
    diffStat: { type: 'string', description: 'Human-readable diff stats' },
    claudeMdPaths: { type: 'array', items: { type: 'string' }, description: 'Paths to CLAUDE.md files found' },
  },
  required: ['diffCommand', 'changedFiles', 'diffStat', 'claudeMdPaths'],
}

// --- Args are intentionally minimal ---
// PR review:    { scope: "pr", repo: "owner/repo", prNumber: 123, skillDir: "..." }
// Local branch: { scope: "branch", skillDir: "..." }
// Staged:       { scope: "staged", skillDir: "..." }
// Last commit:  { scope: "commit", skillDir: "..." }

const safeArgs = args || {}
const scope = safeArgs.scope || 'branch'
const repo = safeArgs.repo || null
const prNumber = safeArgs.prNumber || null
const skillDir = safeArgs.skillDir || null

// --- Phase 1: Context agent ALWAYS runs to gather the correct diff ---

phase('Context')

let contextPrompt
if (scope === 'pr' && repo && prNumber) {
  log(`Gathering context for PR #${prNumber} on ${repo}`)
  contextPrompt = `Gather context for reviewing GitHub PR #${prNumber} on ${repo}.

Run these commands and return structured results:

1. Get changed files (return as array):
   gh pr diff ${prNumber} --repo ${repo} --name-only

2. The diffCommand is exactly: gh pr diff ${prNumber} --repo ${repo}

3. Get diff stats:
   gh pr view ${prNumber} --repo ${repo} --json additions,deletions,changedFiles --template '{{.changedFiles}} files changed, {{.additions}} insertions(+), {{.deletions}} deletions(-)'

4. Find CLAUDE.md files:
   find . -name 'CLAUDE.md' -maxdepth 3 -not -path '*/node_modules/*' 2>/dev/null

Return changedFiles as a JSON array of file path strings. claudeMdPaths as an array (empty array if none found).`
} else {
  log(`Gathering context for local ${scope} review`)
  contextPrompt = `Gather context for a local code review. Scope: ${scope}

Run these commands and return structured results:

1. Detect the base branch:
   git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main"

2. Detect current branch:
   git branch --show-current

3. Based on scope "${scope}":
   - "branch": diffCommand = "git diff origin/<base>...HEAD", get files with --name-only, stats with --stat
   - "staged": diffCommand = "git diff --staged", get files with --name-only, stats with --stat
   - "commit": diffCommand = "git show HEAD", get files with --name-only --diff-filter, stats with --stat

4. Find CLAUDE.md files:
   find . -name 'CLAUDE.md' -maxdepth 3 -not -path '*/node_modules/*' 2>/dev/null

Return changedFiles as a JSON array. claudeMdPaths as an array (empty if none).`
}

const ctx = await agent(contextPrompt, {
  label: 'gather-context', model: 'haiku', schema: CONTEXT_SCHEMA,
})

if (!ctx || !ctx.changedFiles || ctx.changedFiles.length === 0) {
  log('No changed files found — nothing to review')
  return { confirmed: [], stats: { total: 0, deduped: 0, verified: 0, confirmed: 0, agentCount: 0 } }
}

const diffCommand = ctx.diffCommand
const changedFiles = ctx.changedFiles
const diffStat = ctx.diffStat || ''
const claudeMdPaths = ctx.claudeMdPaths || []

log(`Found ${changedFiles.length} changed files: ${changedFiles.slice(0, 5).join(', ')}${changedFiles.length > 5 ? '...' : ''}`)

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

// --- Build shared prompt parts ---

const rulesInstruction = skillDir ? [
  'Read the following rule files for review guidance:',
  `- ${skillDir}/rules/universal.md (ALWAYS)`,
  ...detectedLangs.map(l => `- ${skillDir}/rules/${l}.md (if exists)`),
  '',
  'Read these project guidelines:',
  ...(claudeMdPaths.length > 0 ? claudeMdPaths.map(p => `- ${p}`) : ['(none found)']),
].join('\n') : [
  'Read any CLAUDE.md or project guidelines files found in the repo.',
  ...(claudeMdPaths.length > 0 ? claudeMdPaths.map(p => `- ${p}`) : []),
].join('\n')

const isPR = scope === 'pr' && repo && prNumber

const diffInstruction = [
  `To see the diff under review, run: ${diffCommand}`,
  `Changed files: ${changedFiles.join(', ')}`,
  `Stats: ${diffStat}`,
  ...(isPR ? [
    '',
    `This is a GitHub PR review (PR #${prNumber} on ${repo}).`,
    `To read a file's full content on the PR branch: gh api repos/${repo}/contents/{path}?ref=$(gh pr view ${prNumber} --repo ${repo} --json headRefName -q .headRefName) --jq .content | base64 -d`,
  ] : []),
].join('\n')

const falsePositiveGuidance = `
DO NOT flag:
- Pre-existing issues not introduced in this diff
- Issues linters/typecheckers/compilers catch (formatting, types, imports)
- General code quality unless explicitly in project guidelines (CLAUDE.md)
- Issues on lines not modified in this diff
- Pure style nitpicks unrelated to correctness
- Intentional behavior explained by surrounding context

DO flag even if minor:
- Missing error handling for operations that can fail
- Missing edge case handling in parsing/validation
- Potential null/undefined/nil access without guards
- Resource leaks on error paths
- Test coverage gaps for new code paths
- Security vulnerabilities (injection, secrets, auth bypass)
`

const basePromptParts = (role, focus) => [role, '', rulesInstruction, '', diffInstruction, '', focus, '', falsePositiveGuidance,
  '', 'Score each finding 0-100 on confidence that it is a real NEW issue in this diff.'].join('\n')

// --- Build agent list scaled by diff size ---

const fileCount = changedFiles.length
const agentConfig = []

agentConfig.push({
  label: 'deep-bug-scan',
  effort: 'high',
  prompt: basePromptParts(
    'You are a deep bug scanner.',
    `Read the FULL content of every changed file (not just the diff). Scan at multiple depths:

**Surface**: Typos, wrong variable names, missing returns, copy-paste errors.
**Logic**: Trace through conditionals and loops with concrete example inputs. For each branch, construct an input that takes that path.
**Edge cases**: Empty inputs, boundary values, malformed data, single-item collections, zero/negative, very large inputs.
**Cross-function**: Read callees of changed functions. Verify return value contracts, error propagation, state assumptions.
**Refactoring regressions**: When code is reorganized, verify non-default values (thresholds, timeouts, config) survived the move.
**Guard correctness**: For each conditional guard, verify it handles the ACTUAL type space correctly.
**Incomplete coverage**: For switch/if-else/match chains, ask what the COMPLETE set of runtime inputs is and whether all are handled.`
  ),
})

agentConfig.push({
  label: 'failure-modes',
  prompt: basePromptParts(
    'You are a failure mode and execution scope analyst.',
    `For every changed function/method, analyze:

**Error paths**: What happens when each operation fails? Are all error returns checked?
**Async safety**: Unhandled rejections/panics? Fire-and-forget without error handling? Missing timeouts?
**Resource management**: Files, connections, locks — released on ALL paths including errors?
**Concurrency**: Shared mutable state? Race conditions? Deadlock potential?

**Execution scope mismatch** — ask "where does this code actually run?":
- Module-level code that does I/O or instantiates resources unconditionally
- Code in hot paths that should be lazy/cached
- Code assumed to run once but placed where it runs repeatedly
- Subscriptions/timers without cleanup

Ask: "If I were trying to break this code, what input would I use?"`
  ),
})

agentConfig.push({
  label: 'security',
  prompt: basePromptParts(
    'You are a security specialist.',
    `Check for:
- **Injection**: SQL, command, XSS, LDAP, template injection via string interpolation in queries/commands
- **Auth/Authz**: Missing auth checks, privilege escalation, insecure session handling
- **Secrets**: Hardcoded credentials, API keys, tokens, connection strings
- **Input validation**: Missing or insufficient validation at trust boundaries
- **Crypto**: Weak algorithms, hardcoded IVs/salts, homebrew crypto
- **Data exposure**: Error messages leaking internals, overly verbose logging, PII in logs
- **Unsafe operations**: Deserialization of untrusted data, unsafe file operations, path traversal`
  ),
})

if (fileCount > 3) {
  agentConfig.push({
    label: 'context-and-patterns',
    prompt: basePromptParts(
      'You are a historical context and pattern analyst.',
      `**Historical context**:
- Run \`git blame\` on modified files. Understand WHY the code was written this way.
- Run \`git log --oneline -10 -- <file>\` for each modified file.
- Do these changes break patterns that were deliberately established?

**Related code**:
- Read sibling files and related modules
- Check for patterns that should be followed consistently
- Look for inconsistencies with existing code style

**Code comment compliance**:
- Do changes contradict documented behavior in comments?
- Check TODOs/FIXMEs — are any addressed or introduced?

**Convention compliance**:
- Read CLAUDE.md/project guidelines. Flag violations of explicitly stated conventions.`
    ),
  })

  agentConfig.push({
    label: 'tests-and-quality',
    prompt: basePromptParts(
      'You are a test coverage and code quality reviewer.',
      `**Test coverage gaps**:
- New code paths: Is there a test for each?
- Conditional branches: Are all branches tested?
- Error handling: Are error paths tested?
- Edge cases: Corresponding test cases?
- Critical paths (auth, data integrity): Proportionate coverage?

**Test quality**:
- Tests verify behavior, not implementation details?
- Flakiness risks (timing, external state, order-dependent)?

**Simplification**:
- Abstractions that don't pull their weight?
- Could achieve same result with less code?
- Over-configured solutions for simple problems?
- Premature abstractions (helpers used once, unnecessary indirection)?`
    ),
  })
}

if (fileCount > 15) {
  agentConfig.push({
    label: 'performance',
    prompt: basePromptParts(
      'You are a performance analyst.',
      `Check for:
- N+1 query patterns
- Blocking I/O in async contexts
- Unnecessary recomputations in hot paths
- Memory leaks (unclosed resources, growing collections without eviction)
- Missing pagination for large datasets
- Expensive operations that should be cached or batched
- String concatenation in loops instead of builders/joins
- Unnecessary copies of large data structures`
    ),
  })

  agentConfig.push({
    label: 'deployment-safety',
    prompt: basePromptParts(
      'You are a deployment safety reviewer.',
      `**Breaking changes**: Public API modifications? Type/interface changes that break consumers?
**Migration safety**: Database migrations that lock tables? Data backfill issues?
**Backwards compatibility**: Works with existing production data/state?
**Rollback safety**: Can this be safely rolled back?
**Observability**: If this fails in production, how would we know? Are errors observable?
**Dependency changes**: New deps justified? Well-maintained? Known vulnerabilities?`
    ),
  })
}

// --- Phase 2: Review ---

phase('Review')
log(`Launching ${agentConfig.length} review agents for ${fileCount} changed files`)

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
  return { confirmed: [], stats: { total: 0, deduped: 0, verified: 0, confirmed: 0, agentCount: agentConfig.length } }
}

// --- Dedup by file + overlapping line range + category ---

const deduped = []
for (const f of allFindings) {
  const overlap = deduped.find(d =>
    d.file === f.file &&
    d.category === f.category &&
    Math.abs(d.line_start - f.line_start) <= 5
  )
  if (overlap) {
    overlap.self_score = Math.min(100, Math.max(overlap.self_score, f.self_score) + 10)
    if (f.evidence && (!overlap.evidence || f.evidence.length > overlap.evidence.length)) {
      overlap.evidence = f.evidence
    }
    if (f.suggested_fix && (!overlap.suggested_fix || f.suggested_fix.length > overlap.suggested_fix.length)) {
      overlap.suggested_fix = f.suggested_fix
    }
  } else {
    deduped.push({ ...f })
  }
}

log(`${deduped.length} unique findings after dedup`)

const worthVerifying = deduped.filter(f => f.self_score >= 40)
log(`${worthVerifying.length} findings above self-score threshold for verification`)

if (worthVerifying.length === 0) {
  return { confirmed: [], stats: { total: allFindings.length, deduped: deduped.length, verified: 0, confirmed: 0, agentCount: agentConfig.length } }
}

// --- Phase 3: Adversarial Verification ---

phase('Verify')
log(`Launching ${worthVerifying.length} adversarial verifiers`)

const verifications = await parallel(
  worthVerifying.map(f => () =>
    agent(
      `You are an adversarial verifier. Try to REFUTE this finding. Default to refuted=true if uncertain.

**Finding:**
- File: ${f.file}, Line: ${f.line_start}-${f.line_end}
- Category: ${f.category}, Severity: ${f.severity}
- Title: ${f.title}
- Description: ${f.description}
${f.evidence ? '- Evidence: ' + f.evidence : ''}

**Steps:**
1. Read the file ${f.file} around line ${f.line_start}
2. Run \`${diffCommand}\` to confirm this is in the current changes (not pre-existing)
3. Try to refute:
   - Is this pre-existing, not introduced in this diff?
   - Is the code actually correct (false positive)?
   - Does surrounding context show this is intentional?
   - Would the language/runtime prevent this?
   - Is this stylistic preference, not a real issue?

Be skeptical. False positives waste the author's time.`,
      {
        label: `verify:${f.file}:${f.line_start}`,
        phase: 'Verify',
        model: 'haiku',
        effort: 'medium',
        schema: VERDICT_SCHEMA,
      }
    )
  )
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
  stats: {
    total: allFindings.length,
    deduped: deduped.length,
    verified: worthVerifying.length,
    confirmed: confirmed.length,
    agentCount: agentConfig.length,
  },
}
