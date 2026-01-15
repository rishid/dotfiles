# Git Guidelines

## Git Operations Principles

YOU MUST: Use Git MCP server tools for all Git operations when available
YOU MUST: Only use command line Git operations for functions not supported by the Git MCP server
YOU MUST: Prioritize Git MCP server tools over bash commands for Git operations

## Commit Granularity Enforcement

**ABSOLUTE COMMIT REQUIREMENTS:**

YOU MUST: Analyze ALL changes before creating any commit
YOU MUST: Identify logical units of work and separate them appropriately
YOU MUST: NEVER mix unrelated changes in a single commit

**MANDATORY COMMIT SEPARATION RULES:**

NEVER: Combine different types of changes (feature + bugfix, refactor + new feature)
NEVER: Mix changes to different functional areas or components
NEVER: Include multiple independent bug fixes in one commit
NEVER: Combine configuration changes with code functionality changes

**REQUIRED COMMIT ANALYSIS PROCESS:**

1. Review ALL staged and unstaged changes
2. Identify distinct logical units of work
3. Group related changes that belong together
4. Propose separate commits for each logical unit
5. Ask user to confirm the commit separation strategy
6. Execute commits in logical order

**COMMIT SPLITTING CRITERIA:**

Split commits when changes involve:

- Different features or functionality
- Different bug fixes
- Different components or modules
- Different types of changes (code vs config vs docs)
- Changes that could be deployed independently

**ACCEPTABLE BUNDLING:**

Allow same commit for:

- Related code and its tests
- Feature implementation and its documentation
- Bug fix and its test case
- Configuration changes that directly support the same feature

## Quality Assurance

YOU MUST: Ensure each commit represents a complete, functional unit
YOU MUST: Verify that each commit could theoretically be deployed independently
YOU MUST: Check that commit messages accurately describe the changes
