---
name: frontend-design
description: Use when designing or materially reshaping a user interface's visual layout, typography, content, or interaction.
license: Complete terms in LICENSE.txt
---

# Frontend Design

Start with the user's brief and the product's existing design system. Preserve established components, tokens, and brand conventions unless the task calls for a change. Explicit user instructions take precedence over these guidelines. Do not invent a client's history, preferences, audience, or appetite for visual novelty.

## Understand the interface

Read the relevant UI and content before making visual choices. Identify the page's or component's job, its users, the information hierarchy, and any visual direction supplied by the brief. Ask a focused question only when the missing answer would materially change the result; otherwise make a reasonable assumption and proceed.

For a new direction, choose a small set of color, type, spacing, and layout decisions that support the content. For an existing product, work within its system. Distinctive styling can help when the brief calls for it, but familiarity, restraint, or a conventional pattern may better serve the user. No palette, typeface, layout, or visual treatment is categorically forbidden.

## Make deliberate choices

- **Typography:** Choose typefaces and a readable scale appropriate to the brand and content. Use clear hierarchy, comfortable line lengths and spacing, and consistent weights. One family or a complementary pair can both work.
- **Structure:** Let layout, grouping, borders, labels, and numbering communicate relationships. Number items when sequence or rank is meaningful. Use cards, editorial layouts, gradients, dark themes, or other styles when they fit the brief and the design system.
- **Content:** Use real provided content where possible. Keep placeholder copy specific to the interface's purpose. Write labels and actions in plain language; name an action consistently through its flow. Explain errors and empty states with useful next steps.
- **Motion:** Use animation to clarify state changes or draw attention when it helps. Keep it restrained, respect reduced-motion preferences, and ensure the interface remains understandable without motion.
- **Accessibility and responsiveness:** Check contrast, readable text, semantic structure, keyboard focus and interaction, and layouts from narrow mobile widths through larger screens. Make controls usable by touch and keyboard.

Review the rendered interface as you build. Use screenshots or a browser when available to catch spacing, hierarchy, overflow, and responsive problems that code inspection may miss. Compare the result with the brief and existing design system; adjust only what improves the user's task. Keep CSS selectors and component styles clear enough that they do not cancel one another unexpectedly.
