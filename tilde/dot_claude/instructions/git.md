# Git Guidelines

## Git Operations Principles

YOU MUST: Use Git MCP server tools for all Git operations when available
YOU MUST: Only use command line Git operations for functions not supported by the Git MCP server
YOU MUST: Prioritize Git MCP server tools over bash commands for Git operations

## Commits and branches

Explicit user instructions take precedence over these guidelines. Before committing, review staged and unstaged changes and stage only the intended work. Split independent changes into coherent commits; keep related code, tests, documentation, and configuration together. Ask about commit grouping only when the answer would materially affect the result.

Follow the repository's branch and review rules. A simple request to commit means commit the intended changes on the current branch; if that would violate a protected-branch or required-PR policy, create a branch and follow the required review path. Do not infer permission to pull, push, or open a pull request solely from a commit request.

## Quality Assurance

YOU MUST: Ensure each commit represents a complete, functional unit
YOU MUST: Check that commit messages accurately describe the changes
When opening a pull request, describe the final behavior and why it changed, include relevant validation, and note material limitations. Keep the description proportionate to the change.
