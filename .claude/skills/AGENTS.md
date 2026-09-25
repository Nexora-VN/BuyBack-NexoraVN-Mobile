# AGENTS.md

## Project context

This repository is a production **buyback / cashback / rewards** product. The UI should feel commercially credible, fast, trustworthy, and easy to scan. It may take product inspiration from ShopBack, but it must not copy ShopBack's branding, wording, assets, or page composition.

`AWESOME_DESIGN.md` is the design authority for all frontend work in this repository. Read it before creating or changing any user-facing interface.

## Existing project first

Before editing UI, inspect the relevant existing implementation:

1. Package manager and framework configuration.
2. Global styles and theme variables.
3. Tailwind/theme configuration, if present.
4. Shared layout and UI components.
5. Existing button, input, card, modal, table, toast, and typography patterns.
6. Nearby pages and tests that establish local conventions.

Reuse established tokens and good patterns. Do not replace the current primary brand color, redesign the whole theme, introduce a second dominant palette, or add a new UI library without a clear need.

## Working rules

- Preserve business logic, API contracts, routing, analytics, authorization, SEO, and localization unless the task explicitly changes them.
- Make the smallest coherent change that fully solves the requested UI problem.
- Prefer reusable components when a pattern appears more than once or is likely to recur.
- Keep components focused. Extract meaningful product concepts, not wrappers that merely rename a `div`.
- Use semantic HTML and accessible primitives.
- Follow the repository's naming, folder, import, formatting, linting, and testing conventions.
- Do not add dependencies when existing code or platform APIs are sufficient.
- Do not leave dead code, fake handlers, unexplained placeholders, or commented-out alternatives.
- Do not hardcode colors when an equivalent theme token exists.
- Do not invent backend data. If data is unavailable, implement an explicit loading, empty, or error state.

## UI implementation standard

Every changed screen must:

- Make the primary user goal obvious.
- Give cashback/reward value stronger hierarchy than secondary metadata.
- Clearly distinguish merchant discount from platform cashback.
- Support realistic long merchant names, large monetary values, and missing optional data.
- Include relevant default, hover, focus-visible, active, disabled, and loading states.
- Include useful empty and error states for data-driven areas.
- Work at 375px, 768px, 1024px, and 1280px or the closest existing project breakpoints.
- Avoid accidental horizontal overflow.
- Maintain usable touch targets, generally at least 44 by 44 CSS pixels on touch interfaces.
- Remain usable with keyboard navigation and visible focus.
- Never communicate status by color alone.

## Preferred product components

Reuse existing equivalents before creating new ones. Common concepts include:

- `MerchantCard`
- `DealCard`
- `CashbackBadge`
- `CashbackAmount`
- `PromoBanner`
- `TransactionItem`
- `StatusBadge`
- `SearchBox`
- `SectionHeader`
- `EmptyState`

Names should follow local repository conventions; the list describes concepts, not mandatory identifiers.

## Visual guardrails

- Use the existing primary color mainly for primary actions, rewards, selected states, and purposeful highlights.
- Prefer neutral backgrounds, clear surfaces, borders, and spacing over strong shadows.
- Keep commerce layouts compact and scannable; avoid oversized padding and decorative dead space.
- Use one icon family already present in the project.
- Preserve merchant logo aspect ratios with `object-fit: contain` or the framework equivalent.
- Use subtle motion, normally 120–250ms, and respect reduced-motion preferences.
- Avoid generic AI styling: excessive gradients, glassmorphism, giant pills, oversized headings, random purple/blue accents, heavy shadows, arbitrary illustrations, and unnecessary animations.

## Content and terminology

Use one approved product term consistently, such as `Cashback`, unless different terms have distinct business meanings. Interface copy should be concise, specific, and action-oriented.

Good CTA examples:

- Shop & Earn
- Activate Cashback
- Withdraw Cashback
- Get Deal
- Continue

Do not place several equally prominent primary actions in the same section.

Transaction states must include a text label and, where useful, a short explanation. Typical states are Tracked, Pending, Confirmed, Withdrawable, Paid, and Rejected. Match actual domain enums and translations in the codebase.

## Quality checks

After implementation, run the narrowest relevant existing checks, then broader checks when practical:

1. Formatter or format check.
2. Linter.
3. Type checker.
4. Relevant unit/component tests.
5. Build, when the change or repository warrants it.

Review changed UI at mobile and desktop widths. Verify loading, empty, error, long-content, keyboard, focus, and overflow behavior. If browser or visual-regression tooling exists, use it and inspect the rendered result rather than relying only on source code.

## Completion report

When handing off a UI change, state:

- What changed.
- Which files changed.
- Which checks ran and their results.
- Any remaining assumption or unverified behavior.

Do not claim a test, build, accessibility check, or visual review was completed unless it was actually performed.
