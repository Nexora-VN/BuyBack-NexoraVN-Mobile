# Awesome Design System — Buyback / Cashback

## 1. Product direction

This product is a buyback, cashback, and rewards platform. Its interface should feel:

- Trustworthy with money.
- Rewarding without feeling childish.
- Modern but familiar.
- Fast and conversion-oriented.
- Compact enough to scan many stores and deals.

The product already has an established primary brand color. Preserve it. Reuse existing design tokens and derive supporting colors from the current palette. Never import another product's brand palette.

The target character is:

> Commerce + Rewards + Trust + Speed

It should not feel like a generic SaaS dashboard.

## 2. Core principles

### Clear value first

Users should quickly understand:

1. Which merchant or deal this is.
2. How much cashback or reward they can earn.
3. Whether the offer is active and what conditions apply.
4. What action starts earning.

Cashback values should visually outrank descriptions and metadata.

### One obvious next action

Each page or section should have one clear primary action. Secondary actions should use secondary, ghost, or text treatments.

### Existing system first

Before adding styles, inspect global CSS, theme variables, Tailwind configuration, typography, and shared components. Reuse good existing patterns. A new screen must look native to this product.

### Trust through clarity

Show tracking state, expected confirmation timing, withdrawal state, transaction ID, conditions, and support access where relevant. Do not hide important reward conditions behind unclear interactions.

## 3. Design tokens

Use the repository's existing token names. The following names describe required semantic roles and may be mapped to equivalent project tokens:

```css
--brand-primary;
--brand-primary-hover;
--brand-primary-soft;
--brand-primary-foreground;

--background;
--surface;
--surface-secondary;
--foreground;
--foreground-muted;
--foreground-subtle;
--border;
--border-strong;

--success;
--warning;
--danger;
--info;
--cashback;
--cashback-soft;
```

Never hardcode a color when an equivalent token exists.

```tsx
// Avoid
<div className="bg-[#ff5500] text-gray-500" />

// Prefer the project's semantic tokens
<div className="bg-primary text-muted-foreground" />
```

Recommended visual distribution:

- 70% neutral/background.
- 20% surfaces and supporting UI.
- 10% brand, CTA, reward, and selected states.

Reserve saturated brand color for meaningful emphasis. Large saturated areas are appropriate only for deliberate campaigns.

## 4. Layout and responsive behavior

Use the project's existing application container. If none exists, use a maximum width near 1280px with centered layout and responsive horizontal padding.

```css
max-width: 1280px;
margin-inline: auto;
padding-inline: 24px;
```

Build mobile-first. Review at these reference widths or the project's nearest breakpoints:

| Viewport | Reference width |
| --- | ---: |
| Mobile | 375px |
| Tablet | 768px |
| Laptop | 1024px |
| Desktop | 1280px+ |

Desktop merchant grids generally show 3–5 cards per row. Mobile layouts show 1–2, depending on card density. Never assume a desktop table, modal, or navigation automatically works on mobile.

## 5. Spacing, radius, and elevation

Use an 8px-based rhythm with practical half-steps:

```text
4, 8, 12, 16, 20, 24, 32, 40, 48, 64
```

Most component spacing should use 8, 12, 16, 24, or 32. Avoid arbitrary values unless matching an established design.

Suggested radius hierarchy, adapted to existing tokens:

| Element | Radius |
| --- | ---: |
| Small controls | 8px |
| Buttons and inputs | 10–12px |
| Cards | 12–16px |
| Large campaign surfaces | 16–24px |
| True pills | 9999px |

Do not make every element pill-shaped. Cards should primarily use surface, border, and spacing. Reserve soft shadows for elevated elements such as menus, popovers, sticky headers, floating actions, and dialogs.

## 6. Typography

Use the project's existing font family and type tokens. If no scale exists, use this reference:

| Role | Size | Weight |
| --- | ---: | ---: |
| Page title | 28–32px | 700 |
| Section heading | 20–24px | 600–700 |
| Card title | 15–17px | 600 |
| Body | 14–16px | 400 |
| Metadata | 12–14px | 400–500 |
| Reward value | 18–24px | 700 |

Use bold deliberately. Long names and values must wrap or truncate predictably without moving key actions out of place.

## 7. Reward language

Use product terminology consistently:

```text
5% Cashback
Up to 15% Cashback
Earn 50,000đ
Extra 2% Cashback
Cashback Boost
```

Do not interchange cashback, cash back, rebate, refund, and reward unless they represent different domain concepts.

Merchant discount and platform cashback must be visually and verbally distinct:

```text
20% OFF          Merchant discount
+8% Cashback     Platform reward
```

## 8. Merchant cards

Merchant cards are core reusable components. They should answer three questions immediately: which store, what reward, and how to earn.

Recommended hierarchy:

1. Merchant logo in a consistent aspect-ratio-safe box.
2. Merchant name.
3. Cashback amount with strong emphasis.
4. One concise promotion or condition, when relevant.
5. One primary action.

Supported states should include default, hover, focus-visible, featured, boosted, expired/unavailable, and loading. Hover may adjust border or elevation subtly. Avoid aggressive scaling.

## 9. Deal cards and promotional banners

Deal card order:

1. Merchant.
2. Deal title.
3. Merchant discount.
4. Cashback reward.
5. Conditions and expiration.
6. CTA.

A promotional banner should communicate reward, merchant, deadline, and CTA before decorative copy. Example:

```text
DOUBLE CASHBACK
Shopee
6% → 12%
Ends tonight
[Shop Now]
```

Do not overload cards. Move detailed conditions to an accessible detail view while keeping essential restrictions visible.

## 10. Buttons and controls

Primary buttons use the existing brand token and are reserved for high-value actions such as Shop & Earn, Activate Cashback, Withdraw Cashback, Get Deal, or Continue.

- Secondary: border with neutral or transparent surface.
- Ghost: transparent with a subtle hover surface.
- Destructive: semantic danger token, only for destructive actions.

Controls need default, hover, focus-visible, active, disabled, and loading behavior where relevant. Inputs should include a persistent label, optional helper text, and specific error text. Do not use placeholder text as the only label.

Target control height is 40–44px, with touch targets generally at least 44 × 44 CSS pixels.

## 11. Navigation and search

Desktop navigation may include logo, Stores, Deals, Categories, How It Works, search, cashback balance, and account menu. Mobile bottom navigation should contain no more than 4–5 high-value destinations.

Search is a primary discovery tool. It should support loading, no results, recent searches, popular stores, and autocomplete when available. Results should prioritize logo, store name, cashback amount, and category.

Example placeholder:

```text
Search stores and cashback…
```

## 12. Homepage hierarchy

Recommended order:

1. Header and search.
2. Compact value proposition or active campaign.
3. Popular stores.
4. Cashback boosts.
5. Top deals.
6. Categories.
7. Recommendations.
8. How cashback works.
9. Trust, payment, and security information.
10. Footer.

Show real stores and earning opportunities early. Do not let an oversized hero push the useful product below the fold.

## 13. Cashback dashboard

Balance hierarchy:

1. Available cashback and Withdraw action.
2. Pending cashback.
3. Lifetime earnings.

Available balance receives the strongest emphasis. Monetary values use locale-aware formatting and remain readable at large values.

Cashback history may use a table on desktop and transaction cards on mobile. Important fields include merchant, transaction, purchase amount, cashback, status, and date.

Typical status flow:

```text
Tracked → Pending → Confirmed → Withdrawable → Paid
                               ↘ Rejected
```

Every status requires a text label and semantic presentation; color alone is insufficient. Where useful, explain what the state means and when it is expected to change.

## 14. Feedback states

### Loading

Prefer layout-matched skeletons for stores, deals, balance summaries, and transaction history. Avoid replacing a whole page with a centered spinner when the final layout is predictable.

### Empty

An empty state should explain the situation, recommend a next action, and offer one relevant CTA.

```text
No cashback activity yet
Start shopping through a partner store and your cashback will appear here.
[Explore Stores]
```

### Error

Explain what failed, whether user data or money is safe when relevant, and what the user can do.

```text
We couldn't load your cashback history.
Your cashback data is safe.
[Try Again]
```

Avoid generic messages when more specific context is known.

## 15. Motion and icons

Use the existing icon family consistently. Normal icon sizes are 16, 18, 20, and 24px.

Motion should be subtle and purposeful, usually 120–250ms. Appropriate uses include hover, dropdown, accordion, tab, toast, favorite, copied referral link, and cashback activation feedback. Avoid bounce, large scale changes, continuous motion, and heavy parallax. Respect `prefers-reduced-motion`.

## 16. Images and merchant logos

- Preserve logo aspect ratios.
- Center logos in consistent containers.
- Use `object-fit: contain` for logos.
- Use deliberate, consistent aspect ratios for banners and product imagery.
- Use `object-fit: cover` only when cropping is acceptable.
- Provide meaningful alternative text; use empty alt text for purely decorative images.

## 17. Accessibility

All interfaces must provide:

- Semantic structure and appropriate landmarks.
- Keyboard access and logical focus order.
- Visible focus styles.
- Sufficient text and UI contrast.
- Programmatic labels and useful validation messages.
- Accessible dialog, menu, tabs, and dropdown behavior.
- Status meaning beyond color.
- Reduced-motion support.

Prefer established accessible components already used by the project.

## 18. Anti-patterns

Do not automatically add:

- Excessive gradients or glassmorphism.
- Giant rounded cards or pills everywhere.
- Random purple/blue accents unrelated to the brand.
- Strong shadows on ordinary cards.
- Decorative icons with no meaning.
- Oversized marketing headings.
- Unnecessary dashboard widgets.
- Arbitrary animation.
- Excessive whitespace that reduces commerce scannability.
- Copied ShopBack assets, text, branding, or distinctive layouts.

Every screen should have roughly one primary focus, two to four secondary elements, and quieter supporting information. If everything is emphasized, nothing is emphasized.

## 19. Component strategy

Prefer reusable product components such as merchant cards, deal cards, cashback badges, cashback amounts, promo banners, transaction items, status badges, search boxes, section headers, and empty states. Follow existing naming conventions.

Create a shared component when it expresses a stable product concept or removes meaningful duplication. Do not create abstraction layers for one-off markup without a clear reuse or consistency benefit.

## 20. Final review checklist

### Brand and hierarchy

- Existing palette and tokens are preserved.
- No unnecessary dominant color was introduced.
- Primary action and cashback value are immediately clear.
- Discount and cashback are distinguishable.

### Layout and content

- Spacing and alignment are consistent.
- Commerce content is compact and scannable.
- Long names, large values, and missing optional data are handled.
- Merchant images retain their aspect ratio.

### States and interaction

- Hover, focus, disabled, and loading states exist where relevant.
- Loading, empty, and error experiences are useful.
- Status is not communicated by color alone.
- Motion is subtle and reduced-motion friendly.

### Responsive and accessibility

- 375px, 768px, 1024px, and 1280px+ were reviewed.
- There is no accidental horizontal overflow.
- Keyboard navigation and focus order work.
- Labels, semantics, contrast, and touch targets are appropriate.

### Engineering quality

- Existing components and tokens were reused.
- No unnecessary dependency or duplicated component pattern was added.
- Relevant formatter, lint, typecheck, test, and build commands pass.

When decoration conflicts with clearer cashback information, choose clarity. When a new visual pattern conflicts with a good existing project pattern, prefer the existing pattern.
