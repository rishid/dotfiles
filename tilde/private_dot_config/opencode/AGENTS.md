# Global Instructions

Personal defaults for opencode across all projects. Ported from the Claude Code
instruction set in `~/.claude/instructions/` (those files aren't wired into any
`CLAUDE.md` import, so they weren't actually loaded there — consolidated here so
they're active).

## Editor Configuration

- Always check for `.editorconfig` in the project root before editing files.
- If `.editorconfig` exists, strictly follow its rules: indentation style/size,
  end of line characters, character encoding, final newline, trailing whitespace.

## Code Quality

- Write clear, maintainable code with proper documentation.
- Follow established conventions for the project's language.
- Include appropriate error handling.
- Use meaningful variable and function names.
- Follow DRY, YAGNI, KISS, and SOLID.

### Error handling and debugging

- Investigate and understand the root cause of errors — don't patch around them.
- Never use quick fixes/workarounds, comment out error-causing code, silence
  errors with empty catch blocks, or modify tests just to make them pass.
- Preserve the integrity of existing test cases unless explicitly instructed
  otherwise.
- If unsure about the best approach, ask for guidance.

### Research

- Actively search the web for unfamiliar libraries/frameworks, API docs, best
  practices, error messages, or recent syntax/feature changes — don't assume
  knowledge about rapidly changing technologies.
- If research is insufficient: report what was tried and what's still unknown,
  and ask for guidance rather than filling gaps with assumptions.

## Git

- Prioritize Git MCP server tools over bash commands for Git operations when
  an MCP server is available.
- Analyze all changes before committing; identify logical units of work and
  never mix unrelated changes (different features, different bugfixes,
  different components, code vs. config vs. docs) into a single commit.
- Acceptable to bundle: code with its tests, a feature with its docs, a bugfix
  with its test case, config changes that directly support the same feature.
- Propose the commit split to the user before executing when a change touches
  multiple logical units.

## General Reminders

- Do what's been asked; nothing more, nothing less.
- Prefer editing an existing file over creating a new one.
- Don't proactively create documentation or README files unless requested.
- Don't guess at unclear requirements — ask for clarification instead of
  proceeding on assumptions.
