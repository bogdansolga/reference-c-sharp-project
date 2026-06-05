# Web Front-End Redesign — "Zempler Bank" Visual Identity

**Date:** 2026-06-05
**Branch:** `feat/web-zempler-redesign`
**Scope:** `web/` Next.js front-end only. No API, data-flow, or auth-logic changes.

## Goal

Make the front-end look genuinely professional — a credible demo app for the
*Mastering Claude Code* course. Polish is the point. We commit to one bold,
intentional aesthetic direction rather than the current generic Geist + zinc
grayscale scaffold.

Styling guidance follows the Anthropic `frontend-design` skill: distinctive
fonts over generic defaults, a dominant color with sharp accents, restrained
high-impact motion.

## Decisions (locked during brainstorming)

| Decision | Choice |
|---|---|
| Aesthetic direction | Modern SaaS (light canvas, soft-shadow cards, pill badges) |
| Display font | Bricolage Grotesque (headings + wordmark) |
| Body font | Manrope |
| Palette | Logo-matched: ink-navy + sky-blue (see tokens) |
| Brand | Rebrand app as "Zempler Bank"; add the Zempler logo |
| Theme | Light-only — drop the current `prefers-color-scheme` dark switch |
| Dependencies | Lean: add only `lucide-react`; no component library |
| Chat widget | Out of scope — left as-is |

## Scope

**In scope (core pages):**
- Home (`src/app/page.tsx`)
- Login (`src/app/login/page.tsx`)
- Products list (`src/app/product/page.tsx`)
- Sections list (`src/app/section/page.tsx`)
- New shared `<SiteHeader>` in `src/app/layout.tsx` (the one agreed scope
  expansion beyond "core pages only" — a logo needs a home)
- `src/styles/globals.css` design tokens + fonts
- `src/app/logout-button.tsx` (restyle to match header)

**Out of scope:**
- `src/components/chat-widget.tsx` — untouched
- Any API, repository, service, validation, or auth logic
- Any `.NET`/`api/` changes

## Design System

### Fonts (`next/font/google`, wired in `layout.tsx`)
- `--font-display` → **Bricolage Grotesque** (600/700) — headings, wordmark
- `--font-sans` → **Manrope** (400/500/600/700) — body, UI
- Geist Mono retained only for the login credentials footnote

### Color tokens (CSS variables in `globals.css` `@theme` block)

| Token | Value | Use |
|---|---|---|
| `--brand-ink` | `#04212b` | header bar, headings, primary text |
| `--brand-accent` | `#0a6e94` | primary buttons, links, active nav |
| `--brand-spark` | `#8ad7f5` | light accents, focus rings, badge text on dark |
| `--canvas` | `#f4f8fb` | page background |
| `--surface` | `#ffffff` | cards |
| `--border` | `#d6e6ef` | card / input borders |
| `--badge-bg` | `#e8f6fd` | price / role pills |

Light-only: remove the `@media (prefers-color-scheme: dark)` block and the
`dark:` variants currently scattered across the pages.

## Components & Pages

### Shared shell — `<SiteHeader>`
- Rendered in `layout.tsx` so it appears on every core page.
- Ink-navy bar; left: Zempler mark (`web/public/zempler-logo.png`, downloaded
  from Wikimedia — no hotlinking) + "Zempler Bank" wordmark in Bricolage.
- Right: nav links (Sections / Products) + auth status / logout button.
- Sky-blue active + hover states. Icons from `lucide-react`.

### Home (`page.tsx`)
- Real landing/hero: large Bricolage heading, the full stacked logo,
  auth-aware CTA buttons.
- Keeps existing `getSession()` server logic and `<Suspense>` boundary.
- Chat widget still mounted here, unchanged.

### Login (`login/page.tsx`)
- Centered card on the canvas: bordered surface, branded inputs with sky-blue
  focus rings, accent submit button, credentials in a subtle mono footnote.
- Same client `handleSubmit` / fetch logic; only markup + classes change.

### Products (`product/page.tsx`) & Sections (`section/page.tsx`)
- Card rows: white surface, soft shadow, `--border`, rounded.
- Product price rendered as a sky-blue pill (`--badge-bg` / `--brand-accent`).
- Styled empty states ("No products yet" / "No sections yet").
- Same server-side fetch logic and `<Suspense>` boundaries.

## States & Motion
- Loading: lightweight skeleton rows replacing bare "Loading…" text.
- Empty: styled empty-state blocks.
- Motion: CSS-only staggered fade-in on list rows, gated behind
  `prefers-reduced-motion: reduce`. No motion library.

## Data Flow / Architecture
- Unchanged. Server components stay server components; the login and logout
  client components keep their handlers. The `next.config.ts` API rewrites are
  untouched. This is a presentation-layer redesign only.

## Dependencies
- Add `lucide-react` (icons) and the two Google fonts via `next/font/google`.
- No component library, no motion library.

## Verification
- `cd web && bun run verify:all` (type-check + Biome lint) must pass.
- Manual pass: log in as both `user/user` and `admin/admin`; confirm header,
  nav active states, list rendering, empty states, login flow, and that the
  chat widget still works untouched.

## Out-of-Scope / Non-Goals
- No dark mode.
- No chat-widget restyle.
- No new pages, routes, or CRUD UI (create/edit/delete forms).
- No backend changes.
