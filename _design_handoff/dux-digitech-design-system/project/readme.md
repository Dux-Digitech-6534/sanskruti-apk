# DUX Digitech Design System

**Where business gets digital.** This is the shared design system for DUX Digitech's
product surfaces — starting with **DUX Assistant**, the plain-English ERP query
chatbot — packaged so every future app can be built on one consistent foundation
with **light and dark themes**.

It contains design tokens (colors, type, spacing, motion), brand assets (logo +
monogram), reusable React UI primitives, and a high-fidelity recreation of the DUX
Assistant chat surface.

---

## 1. Product context

DUX Digitech builds business / ERP software, largely on **ERPNext (Frappe, v16)** for
Indian SMBs — purchase orders, suppliers, stock, vouchers, ledgers, migrations, etc.

**DUX Assistant** (the source of this system's visual language) is an in-Desk chat
page. A user types a plain-English question — *"Show pending purchase orders from
Bhandari under 50000"* — and the assistant classifies the intent with a local LLM,
queries ERPNext **as that user** (so permissions are enforced), and returns the exact
records. Its signature idea is **radical transparency**: every result shows the
**filter pills** that actually produced it, so the user can trust and refine the
answer. Amounts are in **₹ (INR)**, formatted in the Indian numbering system.

The surface reads like a **precision instrument**: crisp hairlines, soft ambient
depth, a hairline iris→cyan gradient accent, mono numerics, and restrained
spring-eased micro-motion. It is calm, dense, and data-forward — not playful.

### Sources used to build this system
- **Logo:** `uploads/dux new logo.jpg` (DUX | Digitech wordmark + "Where business gets digital").
- **GitHub — chatbot UI & API:** [`suranaaditya/chatbot`](https://github.com/suranaaditya/chatbot)
  — the chat page (`dux_chatbot_app/.../page/chat/chat.js`) is the **canonical source**
  of this system's tokens, components, and motion; `api.py` informed the product copy,
  the filter-pill transparency model, and the ERP data shapes.
- Related DUX repos worth exploring for product breadth (Tally-style vouchers, ledgers,
  migration dashboards, portals): `suranaaditya/dux_voucher`, `dux_portal`,
  `Acc-Voucher`, `ghrledger`, `Migration-Dashboard`, `tally_migration_app`.

> Explore the chatbot repo above for the richest reference — its `chat.js` carries the
> complete, production-tuned styling these tokens were lifted from.

---

## 2. Content fundamentals — how DUX writes

- **Voice:** plain, professional, operational. Talks to the user as **"you"**; the
  assistant refers to itself as **"DUX"** ("DUX pulls the exact records…", "DUX can
  make mistakes").
- **Plain-English first.** No ERP jargon in the UI chrome. Prompts and labels read like
  a knowledgeable colleague: *"Ask about purchase orders, suppliers, amounts…"*,
  *"Refine within these filters, or start a new search…"*.
- **Transparent & humble.** Always shows its work ("The filters that produced this are
  shown below.") and never over-claims: *"DUX can make mistakes — double-check
  important results."* Errors nudge, never blame: *"I couldn't run that query — I may
  have misunderstood a field or value. Try rephrasing."*
- **Sentence case** everywhere except small **UPPERCASE eyebrow labels** ("SHOWING
  RESULTS FOR", "TRY ASKING") which use wide tracking.
- **Numbers are first-class.** Counts, amounts and IDs are highlighted in mono/cyan
  inline ("Found **12** Purchase Order records, worth **₹4,20,000** in total").
- **No emoji.** Iconography is thin-stroke line icons, never emoji. Tone is confident
  and quiet — the headline *"Ask DUX about your operations"* gradient-accents one word
  ("operations") and stops there.
- **Title/empty headline pattern:** short imperative + one gradient word. Body copy is
  ≤2 sentences, explanatory, reassuring.

---

## 3. Visual foundations

**Color.** Two brand hues on a near-neutral base: **Iris** (`#5C4DE6` light /
`#6D5EF6` dark) is the primary/interactive color; **Cyan** (`#0E9C8B` light / `#2DD4BF`
dark) is the *data* accent — every number, ID, total and amount is cyan + mono. The
base is cool grey: light theme floats white cards on `#F3F4F7`; dark theme is a focused
near-black `#0A0D13` instrument surface. Status is a warm triad: green = approved/paid,
amber = pending/to-receive, rose = error/cancelled. All semantic tokens re-map across
themes — author with `--text-*`, `--bg-*`, `--border-*`, `--brand-*`.

**Type.** **Geist** for all UI (300–700); **JetBrains Mono** for every numeric, ID,
date and timestamp (always `tabular-nums`). Display/headings are tracked tight
(`-.025em`); body is 14.5px / 1.6. Eyebrow labels are 11px UPPERCASE, `.08em` tracking.

**Spacing & radius.** 4px base scale. Radii are generous and soft: 8 / 12 / 16 / 22px,
plus full pills for buttons, tags and chips. Inputs/cards favor 12–16px; the composer
is 22px.

**Backgrounds.** No photography. Surfaces sit on a subtle **ambient wash**
(`--ambient`) — two faint radial glows (iris top-center, cyan top-right) that give depth
without noise. The header uses **backdrop blur + saturate** over the stream. No
repeating patterns or textures.

**Borders & elevation.** Hairlines do most of the structural work (`--hairline` /
`--hairline-2`). Shadows are soft and ambient, not hard drop-shadows — `--shadow-card`
for resting cards, `--shadow-pop` for the composer, paired with an **inset top
highlight** (`--inset-hi`) for a crisp lit edge. The iris send-button carries a colored
glow (`--shadow-brand`). In dark theme shadows deepen and the inset highlight softens.

**The gradient accent.** A single hairline `iris → #4F9FD8 → cyan` gradient
(`--brand-grad`) is the system's signature — used as a 2px top line on result cards and
the filter bar, a 1px masked ring on the brand avatar and focused composer, the send
glow, and a text-clip on one accent word. Used sparingly; never as a full background.

**Motion.** Two eased curves: a **spring** (`cubic-bezier(.22,1,.36,1)`) for entrances
and hovers (settle with a touch of bounce) and a standard **ease** for color/opacity.
Turns settle up + fade in (`duxSettle`). The thinking state sweeps the gradient bar and
gently bobs/floats the brand mark + shimmers text. **Hover** = lift 1–2px + iris border/
color (controls) or 3px slide (list rows). **Press** = settle back + slight scale-down
on the send button. All decorative motion is disabled under
`prefers-reduced-motion: reduce`.

**Transparency & blur.** Used deliberately: header backdrop-blur; tinted status/filter
backgrounds (color at 9–14% alpha); the user bubble is a translucent iris gradient.
Imagery is none — the brand is geometric and monochrome (the DX mark), so there's no
warm/cool photo treatment to manage.

**Cards.** Hairline border + `--shadow-card` + inset highlight + 16px radius, content
edge-to-edge (tables bleed to the border). Optional 2px gradient top accent. Corners are
soft, never sharp; never a colored left-border-only card.

---

## 4. Iconography

- **System:** a bespoke **thin-stroke line set** (24×24, **1.7** stroke, round caps/
  joins, `currentColor`) ported verbatim from the product (`chat.js` → `icons.jsx`).
  Shipped as the **`Icon`** component (`components/brand/Icon.jsx`) — 21 glyphs: filter,
  clock, truck, building, rupee, calendar, box, search, sparkle, send, plus, moon, sun,
  chevron, layers, refresh, check, close, copy, download, user.
- **No icon font, no emoji, no Unicode-as-icon.** Icons are inline SVG via the component.
  Use **`rupee`** for amounts, **`sparkle`** as the assistant/AI glyph, **`clock`/`truck`/
  `building`/`box`/`calendar`** as filter-kind glyphs in pills.
- **Brand mark:** the **DX monogram** (`assets/dux-mark.png` dark / `dux-mark-white.png`
  light-on-dark) is the app/avatar icon. The full wordmark lockup
  (`assets/dux-logo.png` / `dux-logo-white.png`) is for headers, login, marketing. The
  **3D mascot** (`assets/dux-mascot.png`) — the DX glyph with a friendly face — appears
  in empty states, thinking/working moments, and onboarding (never as a UI control).
- If you need a glyph not in the set, add it to `Icon.jsx` in the same 24×24 / 1.7-stroke
  style — do **not** mix in a different icon library.

---

## 5. Index / manifest

**Root**
- `styles.css` — the single entry point consumers link (`@import`s only).
- `tokens/` — `fonts.css`, `colors.css` (light + dark), `typography.css`, `spacing.css`.
- `assets/` — `dux-logo.png` / `dux-logo-white.png` (wordmark), `dux-mark.png` /
  `dux-mark-white.png` (DX monogram), `dux-mascot.png` (3D mascot), `dux-logo-full.jpg`.
- `SKILL.md` — Agent-Skill manifest (for Claude Code download).

**Components** (`components/<group>/` — React, `window.DUXDigitechDesignSystem_a3a609.*`)
- `brand/` — **Icon**, **BrandAvatar**
- `core/` — **Button**, **IconButton**, **Card** (+ **CardMeta**), **Badge**
- `forms/` — **Input**, **Composer** (the signature ask-bar)
- `feedback/` — **StatusTag**, **FilterPill** (+ **FilterBar**), **ThinkingIndicator**

**Foundations** (`guidelines/*.card.html`) — specimen cards shown in the Design System
tab: brand/neutral/text/status/dark colors, display/body/mono type, radii/elevation/
spacing, logo/monogram/gradient.

**UI kits** (`ui_kits/`)
- `chat/` — **DUX Assistant** interactive recreation (`index.html` + `chat-app.jsx` +
  `chat-data.js`): empty state → ask → thinking → transparent result card with filter
  pills + data table, light/dark toggle, "New search".

---

## 6. Theming

Set the theme on any ancestor (usually `<html>`):

```html
<html data-theme="light">  <!-- default -->
<html data-theme="dark">   <!-- instrument surface -->
```

All tokens re-map automatically. Toggle by flipping the attribute (see the chat kit's
theme button).

---

## ⚠ Substitutions to confirm
- **Fonts:** Geist + JetBrains Mono load from **Google Fonts** via `tokens/fonts.css`.
  Both match the product exactly. To self-host, add the `.woff2` files under
  `assets/fonts/` and swap the `@import` for `@font-face` rules.
