---
name: dux-digitech-design
description: Use this skill to generate well-branded interfaces and assets for DUX Digitech (the "DUX Assistant" ERP chat product and future apps), either for production or throwaway prototypes/mocks/etc. Contains essential design guidelines, colors, type, fonts, assets, and UI kit components for prototyping. Covers light and dark themes.
user-invocable: true
---

Read the `readme.md` file within this skill, and explore the other available files.

If creating visual artifacts (slides, mocks, throwaway prototypes, etc), copy assets out
and create static HTML files for the user to view. If working on production code, you can
copy assets and read the rules here to become an expert in designing with this brand.

If the user invokes this skill without any other guidance, ask them what they want to
build or design, ask some questions, and act as an expert designer who outputs HTML
artifacts _or_ production code, depending on the need.

## Quick map
- `readme.md` — full design guide: product context, content/voice, visual foundations, iconography, manifest.
- `styles.css` — single CSS entry point (`@import`s `tokens/*`). Link this; author with the semantic tokens (`--text-*`, `--bg-*`, `--border-*`, `--brand-*`).
- `tokens/` — `colors.css` (light default + `[data-theme="dark"]`), `typography.css`, `spacing.css`, `fonts.css`.
- `assets/` — DX monogram (`dux-mark*.png`) and wordmark (`dux-logo*.png`), light + dark variants.
- `components/` — React primitives: Icon, BrandAvatar, Button, IconButton, Card, Badge, Input, Composer, StatusTag, FilterPill/FilterBar, ThinkingIndicator.
- `ui_kits/chat/` — the DUX Assistant surface, fully recreated and interactive.
- `guidelines/*.card.html` — foundation specimens.

## Non-negotiables
- **Two themes.** Light is default; dark is the focused "instrument" surface. Set `data-theme` on an ancestor; never hard-code hexes — use tokens.
- **Iris = interactive, Cyan = data.** Every number / ID / amount / date is cyan + JetBrains Mono with `tabular-nums`. Amounts are ₹ in the Indian numbering system.
- **Geist** for UI, **JetBrains Mono** for numerics.
- **Thin-stroke line icons only** (use the `Icon` component / its 24×24 1.7-stroke style). No emoji.
- **Transparency motif:** when showing query results, show the filter pills that produced them.
- Soft hairlines + ambient shadows + a single hairline iris→cyan gradient accent, used sparingly. Calm, dense, data-forward — not playful.
