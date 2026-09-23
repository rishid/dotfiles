---
name: vercel-react-best-practices
description: Use for React or Next.js performance work involving request waterfalls, bundle size, server rendering, or measured rerender costs.
license: MIT
---

# React and Next.js performance reference

Use this skill for an explicit performance review or a concrete performance risk in the current change. Ordinary React component edits do not need a performance checklist. The user's instructions and the project's conventions take precedence over these guidelines.

The `rules/` directory contains focused examples from Vercel Engineering's [React Best Practices](https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices). Read only rules that match the code path being changed. Start with the likely cause and verify the result when practical:

- Independent requests or server data loading: [async-parallel](rules/async-parallel.md) and [server-parallel-fetching](rules/server-parallel-fetching.md).
- Large imports or slow startup: [bundle-barrel-imports](rules/bundle-barrel-imports.md) and [bundle-dynamic-imports](rules/bundle-dynamic-imports.md).
- A measured render bottleneck: [rerender-memo](rules/rerender-memo.md) or another matching `rerender-*` rule.

Treat rules as hypotheses, not universal requirements. Check the app's React and Next.js versions, bundler, deployment model, and React Compiler settings before applying version-sensitive advice. Prefer current [React documentation](https://react.dev/) and [Next.js documentation](https://nextjs.org/docs) when they differ from a bundled example. Do not introduce a dependency or cache user-specific data across requests merely because a rule shows an example. Measure before adding manual memoization or low-level JavaScript micro-optimizations.
