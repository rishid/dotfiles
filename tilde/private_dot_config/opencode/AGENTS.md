# Global Instructions

Personal defaults for OpenCode across all projects. Claude Code's corresponding
guidance lives in `~/.claude/CLAUDE.md`.

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
- If research is insufficient, explain the uncertainty and ask for guidance
  when the missing answer would materially change the outcome.

## Git

- Prioritize Git MCP server tools over bash commands for Git operations when
  an MCP server is available.
- For commit and PR requests, follow the `git-workflow` skill and the
  repository's branch and review rules. Review the intended diff and stage only
  related work; keep related code, tests, docs, and configuration together.

## General Reminders

- Do what's been asked; nothing more, nothing less.
- Prefer editing an existing file over creating a new one.
- Don't proactively create documentation or README files unless requested.
- Ask for clarification when an unclear requirement would materially change the
  outcome. Otherwise use a reasonable assumption consistent with the brief.
