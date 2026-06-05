# Web Front-End "Zempler Bank" Redesign — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restyle the `web/` core pages into a polished "Zempler Bank" Modern-SaaS identity (Bricolage Grotesque + Manrope fonts, logo-matched ink+sky-blue palette, shared header, light-only) without touching API, auth, or data-flow logic.

**Architecture:** Presentation-layer only. Design tokens live in `globals.css` (`@theme` block). Fonts load via `next/font/google` in `layout.tsx`, which also renders a new server `<SiteHeader>`. Each core page keeps its existing server/client logic and `<Suspense>` boundaries — only markup and Tailwind classes change.

**Tech Stack:** Next.js 16, React 19, Tailwind CSS 4, `next/font/google`, `lucide-react` (new), Biome (lint/format, double quotes), Bun.

**Branch:** `feat/web-zempler-redesign` (already created and checked out).

**Spec:** `docs/superpowers/specs/2026-06-05-web-zempler-redesign-design.md`

---

## Testing note (read first)

`web/` has **no unit-test framework** — `bun run verify:all` runs `tsc --noEmit` + `biome check` only. This is a visual redesign, so "verification" for each task is:

1. **`cd web && bun run verify:all`** — must pass (type-check + lint).
2. **Manual check** where called out — run `bun dev`, log in, eyeball the page.

There is intentionally no TDD red/green cycle here; there is nothing meaningful to assert in a unit test for CSS classes. Commit after each task.

All commands below assume you are in the repo root unless they start with `cd web`. All `git commit` messages must end with the project's `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>` trailer.

---

## File Structure

| File | Action | Responsibility |
|---|---|---|
| `web/package.json` | Modify | Add `lucide-react` dependency |
| `web/public/zempler-logo.png` | Create | Brand logo asset (downloaded) |
| `web/src/styles/globals.css` | Modify | Design tokens, fonts, remove dark mode |
| `web/src/app/layout.tsx` | Modify | Load fonts, set metadata, render `<SiteHeader>` |
| `web/src/components/site-header.tsx` | Create | Shared ink-navy header (logo + nav + auth) |
| `web/src/app/logout-button.tsx` | Modify | Restyle for header |
| `web/src/app/page.tsx` | Modify | Landing/hero redesign |
| `web/src/app/login/page.tsx` | Modify | Branded login card |
| `web/src/app/product/page.tsx` | Modify | Card rows + price pill + states |
| `web/src/app/section/page.tsx` | Modify | Card rows + states |

---

## Task 1: Add the logo asset and `lucide-react`

**Files:**
- Create: `web/public/zempler-logo.png`
- Modify: `web/package.json`

- [ ] **Step 1: Download the logo into `public/`**

```bash
mkdir -p web/public
curl -sL -A "Mozilla/5.0" \
  "https://upload.wikimedia.org/wikipedia/commons/9/90/Zempler_Bank_logo.png" \
  -o web/public/zempler-logo.png
file web/public/zempler-logo.png
```

Expected: `web/public/zempler-logo.png: PNG image data, 800 x 800, 8-bit/color RGBA, non-interlaced`

- [ ] **Step 2: Add the icon dependency**

```bash
cd web && bun add lucide-react
```

Expected: `lucide-react` appears under `dependencies` in `web/package.json`.

- [ ] **Step 3: Verify install + lint**

```bash
cd web && bun run verify:all
```

Expected: PASS (no type or lint errors).

- [ ] **Step 4: Commit**

```bash
git add web/public/zempler-logo.png web/package.json web/bun.lock
git commit -m "[dev] Add Zempler logo asset and lucide-react"
```

---

## Task 2: Design tokens and fonts in `globals.css`

**Files:**
- Modify: `web/src/styles/globals.css`

- [ ] **Step 1: Replace the top of `globals.css` (tokens, theme, light-only)**

Replace the current lines 1–26 (the `@import`, `:root`, `@theme inline`, dark-mode `@media`, and `body` blocks) with the following. **Keep the existing `.chat-markdown { … }` block below it unchanged.**

```css
@import "tailwindcss";

:root {
  /* Zempler Bank palette (logo-matched: ink navy + sky blue) */
  --brand-ink: #04212b;
  --brand-accent: #0a6e94;
  --brand-spark: #8ad7f5;
  --canvas: #f4f8fb;
  --surface: #ffffff;
  --border: #d6e6ef;
  --badge-bg: #e8f6fd;

  --background: var(--canvas);
  --foreground: var(--brand-ink);
}

@theme inline {
  --color-background: var(--background);
  --color-foreground: var(--foreground);
  --color-brand-ink: var(--brand-ink);
  --color-brand-accent: var(--brand-accent);
  --color-brand-spark: var(--brand-spark);
  --color-canvas: var(--canvas);
  --color-surface: var(--surface);
  --color-border-soft: var(--border);
  --color-badge-bg: var(--badge-bg);

  --font-display: var(--font-bricolage);
  --font-sans: var(--font-manrope);
  --font-mono: var(--font-geist-mono);
}

body {
  font-family: var(--font-sans), system-ui, sans-serif;
  color: var(--foreground);
  background: var(--background);
}

/* Staggered list reveal — disabled when the user prefers reduced motion */
@keyframes row-in {
  from { opacity: 0; transform: translateY(6px); }
  to { opacity: 1; transform: none; }
}
.row-reveal {
  animation: row-in 0.35s ease both;
}
@media (prefers-reduced-motion: reduce) {
  .row-reveal { animation: none; }
}
```

- [ ] **Step 2: Verify**

```bash
cd web && bun run verify:all
```

Expected: PASS. (CSS isn't type-checked, but Biome must not error and the file must be valid.)

- [ ] **Step 3: Commit**

```bash
git add web/src/styles/globals.css
git commit -m "[feat] Add Zempler design tokens; drop dark mode in web"
```

---

## Task 3: Load fonts and metadata in `layout.tsx`

**Files:**
- Modify: `web/src/app/layout.tsx`

- [ ] **Step 1: Replace the full contents of `layout.tsx`**

`<SiteHeader>` is added in Task 4; this task wires fonts + metadata and leaves the body markup ready for it. (The import is added in Task 4 to keep this task self-contained and lint-clean.)

```tsx
import type { Metadata } from "next";
import { Bricolage_Grotesque, Geist_Mono, Manrope } from "next/font/google";
import "@/styles/globals.css";

const bricolage = Bricolage_Grotesque({
  variable: "--font-bricolage",
  subsets: ["latin"],
  weight: ["600", "700"],
});

const manrope = Manrope({
  variable: "--font-manrope",
  subsets: ["latin"],
  weight: ["400", "500", "600", "700"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Zempler Bank",
  description: "Product and section management — Zempler Bank",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body
        className={`${bricolage.variable} ${manrope.variable} ${geistMono.variable} min-h-screen bg-canvas text-brand-ink antialiased`}
      >
        {children}
      </body>
    </html>
  );
}
```

- [ ] **Step 2: Verify**

```bash
cd web && bun run verify:all
```

Expected: PASS.

- [ ] **Step 3: Commit**

```bash
git add web/src/app/layout.tsx
git commit -m "[feat] Wire Bricolage + Manrope fonts and Zempler title"
```

---

## Task 4: Shared `<SiteHeader>` component

**Files:**
- Create: `web/src/components/site-header.tsx`
- Modify: `web/src/app/layout.tsx` (add import + render)
- Modify: `web/src/app/logout-button.tsx`

- [ ] **Step 1: Create `web/src/components/site-header.tsx`**

Server component. Reuses the existing `getSession()` from `@/lib/auth`. Logo via `next/image`, cropped to the circular mark with `object-position`.

```tsx
import Image from "next/image";
import Link from "next/link";
import { getSession } from "@/lib/auth";
import { LogoutButton } from "@/app/logout-button";

export async function SiteHeader() {
  const session = await getSession();

  return (
    <header className="bg-brand-ink text-white">
      <div className="mx-auto flex max-w-5xl items-center justify-between px-6 py-3">
        <Link className="flex items-center gap-3" href="/">
          <span className="overflow-hidden rounded-lg bg-white">
            <Image
              alt="Zempler Bank"
              className="h-9 w-9 object-cover"
              height={36}
              src="/zempler-logo.png"
              style={{ objectPosition: "center 22%" }}
              width={36}
            />
          </span>
          <span className="font-display font-bold text-lg tracking-tight">Zempler Bank</span>
        </Link>

        <nav className="flex items-center gap-5 text-sm">
          <Link className="font-medium text-zinc-300 transition-colors hover:text-brand-spark" href="/section">
            Sections
          </Link>
          <Link className="font-medium text-zinc-300 transition-colors hover:text-brand-spark" href="/product">
            Products
          </Link>
          {session ? (
            <div className="flex items-center gap-3 border-white/15 border-l pl-5">
              <span className="text-zinc-400">
                {session.user.username} <span className="text-brand-spark">({session.user.role})</span>
              </span>
              <LogoutButton />
            </div>
          ) : (
            <Link
              className="rounded-md bg-brand-accent px-3 py-1.5 font-semibold text-white transition-colors hover:bg-brand-spark hover:text-brand-ink"
              href="/login"
            >
              Login
            </Link>
          )}
        </nav>
      </div>
    </header>
  );
}
```

- [ ] **Step 2: Restyle `web/src/app/logout-button.tsx` for the dark header**

Logic unchanged — only the className and an icon change.

```tsx
"use client";

import { LogOut } from "lucide-react";
import { useRouter } from "next/navigation";

export function LogoutButton() {
  const router = useRouter();

  async function handleLogout() {
    await fetch("/api/auth/logout", { method: "POST" });
    router.push("/login");
    router.refresh();
  }

  return (
    <button
      className="flex items-center gap-1.5 text-sm text-zinc-400 transition-colors hover:text-brand-spark"
      onClick={handleLogout}
      type="button"
    >
      <LogOut className="h-4 w-4" />
      Logout
    </button>
  );
}
```

- [ ] **Step 3: Render `<SiteHeader>` in `layout.tsx`**

Add the import at the top of `web/src/app/layout.tsx`:

```tsx
import { SiteHeader } from "@/components/site-header";
```

Then wrap children so the header renders on every page. Replace the `<body>…</body>` block from Task 3 with:

```tsx
      <body
        className={`${bricolage.variable} ${manrope.variable} ${geistMono.variable} min-h-screen bg-canvas text-brand-ink antialiased`}
      >
        <SiteHeader />
        {children}
      </body>
```

- [ ] **Step 4: Verify + manual check**

```bash
cd web && bun run verify:all
```

Expected: PASS. Then `cd web && bun dev`, open http://localhost:3000 — the ink header with the Zempler mark, wordmark, nav links, and Login button (logged out) renders on the home page. (Requires the C# API running for `getSession`; if the API is down the header still renders logged-out.)

- [ ] **Step 5: Commit**

```bash
git add web/src/components/site-header.tsx web/src/app/logout-button.tsx web/src/app/layout.tsx
git commit -m "[feat] Add shared Zempler site header with auth-aware nav"
```

---

## Task 5: Home / landing redesign

**Files:**
- Modify: `web/src/app/page.tsx`

- [ ] **Step 1: Replace the full contents of `page.tsx`**

Keeps `getSession()`, the `<Suspense>` boundary, and `<ChatWidget />`. The header now owns nav/logout, so the home body becomes a hero. Auth-aware CTAs remain.

```tsx
import Image from "next/image";
import Link from "next/link";
import { Suspense } from "react";
import { ChatWidget } from "@/components/chat-widget";
import { getSession } from "@/lib/auth";

async function HeroActions() {
  const session = await getSession();

  if (session) {
    return (
      <div className="flex flex-col items-center gap-3">
        <p className="text-sm text-zinc-500">
          Signed in as <span className="font-semibold text-brand-ink">{session.user.username}</span> ({session.user.role})
        </p>
        <div className="flex gap-3">
          <Link
            className="rounded-lg bg-brand-accent px-5 py-2.5 font-semibold text-white transition-colors hover:bg-brand-ink"
            href="/section"
          >
            Browse Sections
          </Link>
          <Link
            className="rounded-lg border border-border-soft bg-surface px-5 py-2.5 font-semibold text-brand-ink transition-colors hover:border-brand-accent"
            href="/product"
          >
            Browse Products
          </Link>
        </div>
      </div>
    );
  }

  return (
    <Link
      className="rounded-lg bg-brand-accent px-6 py-3 font-semibold text-white transition-colors hover:bg-brand-ink"
      href="/login"
    >
      Get started
    </Link>
  );
}

export default function Home() {
  return (
    <main className="flex min-h-[calc(100vh-64px)] flex-col items-center justify-center px-6 py-16">
      <Image
        alt="Zempler Bank"
        className="mb-8"
        height={120}
        priority
        src="/zempler-logo.png"
        width={120}
      />
      <h1 className="text-center font-display font-bold text-4xl tracking-tight sm:text-5xl">
        Product &amp; Section Management
      </h1>
      <p className="mt-3 max-w-md text-center text-zinc-500">
        A small showcase API and UI for the Mastering Claude Code course. Sign in to browse the catalog.
      </p>

      <div className="mt-8">
        <Suspense fallback={<div className="h-12" />}>
          <HeroActions />
        </Suspense>
      </div>

      <ChatWidget />
    </main>
  );
}
```

- [ ] **Step 2: Verify + manual check**

```bash
cd web && bun run verify:all
```

Expected: PASS. With `bun dev` running, http://localhost:3000 shows the full stacked logo, the Bricolage hero heading, and auth-aware CTAs. Chat widget still opens.

- [ ] **Step 3: Commit**

```bash
git add web/src/app/page.tsx
git commit -m "[feat] Redesign home as branded Zempler landing hero"
```

---

## Task 6: Login page redesign

**Files:**
- Modify: `web/src/app/login/page.tsx`

- [ ] **Step 1: Replace the `return (…)` JSX in `login/page.tsx`**

Keep the entire `"use client"` directive, imports, and the `handleSubmit` / `useState` logic (lines 1–39) **exactly as-is**. Replace only the returned JSX (the `<main>…</main>` block) with:

```tsx
  return (
    <main className="flex min-h-[calc(100vh-64px)] items-center justify-center px-6 py-16">
      <div className="w-full max-w-sm rounded-2xl border border-border-soft bg-surface p-8 shadow-sm">
        <h1 className="mb-1 text-center font-display font-bold text-2xl tracking-tight">Sign in</h1>
        <p className="mb-6 text-center text-sm text-zinc-500">Welcome back to Zempler Bank</p>

        <form className="space-y-4" onSubmit={handleSubmit}>
          <div>
            <label className="mb-1 block font-medium text-sm" htmlFor="username">
              Username
            </label>
            <input
              className="w-full rounded-lg border border-border-soft px-3 py-2 outline-none transition focus:border-brand-accent focus:ring-2 focus:ring-brand-spark"
              id="username"
              onChange={(e) => setUsername(e.target.value)}
              required
              type="text"
              value={username}
            />
          </div>

          <div>
            <label className="mb-1 block font-medium text-sm" htmlFor="password">
              Password
            </label>
            <input
              className="w-full rounded-lg border border-border-soft px-3 py-2 outline-none transition focus:border-brand-accent focus:ring-2 focus:ring-brand-spark"
              id="password"
              onChange={(e) => setPassword(e.target.value)}
              required
              type="password"
              value={password}
            />
          </div>

          {error && <p className="text-red-600 text-sm">{error}</p>}

          <button
            className="w-full rounded-lg bg-brand-accent px-4 py-2.5 font-semibold text-white transition-colors hover:bg-brand-ink disabled:opacity-50"
            disabled={loading}
            type="submit"
          >
            {loading ? "Signing in…" : "Sign in"}
          </button>
        </form>

        <div className="mt-6 rounded-lg bg-badge-bg px-3 py-2 text-center text-sm text-zinc-600">
          <p className="font-medium text-brand-ink">Test credentials</p>
          <p className="font-mono text-xs">user / user · admin / admin</p>
        </div>
      </div>
    </main>
  );
```

- [ ] **Step 2: Verify + manual check**

```bash
cd web && bun run verify:all
```

Expected: PASS. With the API running, visit http://localhost:3000/login, sign in as `admin/admin` — focus rings are sky-blue, submit works, redirect to home succeeds.

- [ ] **Step 3: Commit**

```bash
git add web/src/app/login/page.tsx
git commit -m "[feat] Redesign login as branded card"
```

---

## Task 7: Products page redesign

**Files:**
- Modify: `web/src/app/product/page.tsx`

- [ ] **Step 1: Replace the full contents of `product/page.tsx`**

Keeps the server fetch logic and `<Suspense>` exactly; restyles the list, adds a styled empty state and a price pill. The "← Back" link is dropped (the header now owns navigation).

```tsx
import { cookies } from "next/headers";
import { Suspense } from "react";
import type { ProductResponse } from "@/lib/types/product";

async function ProductList() {
  const cookieStore = await cookies();
  const response = await fetch(`${process.env.API_URL || "http://localhost:5099"}/api/v1/product`, {
    headers: { Cookie: cookieStore.toString() },
    cache: "no-store",
  });
  const products: ProductResponse[] = response.ok ? await response.json() : [];

  if (products.length === 0) {
    return (
      <div className="rounded-xl border border-border-soft border-dashed bg-surface p-10 text-center text-zinc-500">
        No products yet.
      </div>
    );
  }

  return (
    <ul className="space-y-2">
      {products.map((product, i) => (
        <li
          className="row-reveal flex items-center justify-between rounded-xl border border-border-soft bg-surface px-4 py-3 shadow-sm"
          key={product.id}
          style={{ animationDelay: `${i * 40}ms` }}
        >
          <span className="font-medium">{product.name}</span>
          <span className="rounded-full bg-badge-bg px-2.5 py-1 font-semibold text-brand-accent text-sm">
            ${product.price.toFixed(2)}
          </span>
        </li>
      ))}
    </ul>
  );
}

export default function ProductsPage() {
  return (
    <main className="mx-auto max-w-2xl px-6 py-10">
      <h1 className="mb-6 font-display font-bold text-3xl tracking-tight">Products</h1>
      <Suspense fallback={<p className="text-zinc-400">Loading…</p>}>
        <ProductList />
      </Suspense>
    </main>
  );
}
```

- [ ] **Step 2: Verify + manual check**

```bash
cd web && bun run verify:all
```

Expected: PASS. Signed in, http://localhost:3000/product shows card rows with sky-blue price pills and a staggered fade-in.

- [ ] **Step 3: Commit**

```bash
git add web/src/app/product/page.tsx
git commit -m "[feat] Redesign products list with card rows and price pills"
```

---

## Task 8: Sections page redesign

**Files:**
- Modify: `web/src/app/section/page.tsx`

- [ ] **Step 1: Replace the full contents of `section/page.tsx`**

Mirrors the products page treatment (card rows, empty state, fade-in); sections have no price, so no pill.

```tsx
import { cookies } from "next/headers";
import { Suspense } from "react";
import type { SectionResponse } from "@/lib/types/section";

async function SectionList() {
  const cookieStore = await cookies();
  const response = await fetch(`${process.env.API_URL || "http://localhost:5099"}/api/v1/section`, {
    headers: { Cookie: cookieStore.toString() },
    cache: "no-store",
  });
  const sections: SectionResponse[] = response.ok ? await response.json() : [];

  if (sections.length === 0) {
    return (
      <div className="rounded-xl border border-border-soft border-dashed bg-surface p-10 text-center text-zinc-500">
        No sections yet.
      </div>
    );
  }

  return (
    <ul className="space-y-2">
      {sections.map((section, i) => (
        <li
          className="row-reveal rounded-xl border border-border-soft bg-surface px-4 py-3 font-medium shadow-sm"
          key={section.id}
          style={{ animationDelay: `${i * 40}ms` }}
        >
          {section.name}
        </li>
      ))}
    </ul>
  );
}

export default function SectionsPage() {
  return (
    <main className="mx-auto max-w-2xl px-6 py-10">
      <h1 className="mb-6 font-display font-bold text-3xl tracking-tight">Sections</h1>
      <Suspense fallback={<p className="text-zinc-400">Loading…</p>}>
        <SectionList />
      </Suspense>
    </main>
  );
}
```

- [ ] **Step 2: Verify + manual check**

```bash
cd web && bun run verify:all
```

Expected: PASS. Signed in, http://localhost:3000/section shows matching card rows.

- [ ] **Step 3: Commit**

```bash
git add web/src/app/section/page.tsx
git commit -m "[feat] Redesign sections list with card rows"
```

---

## Task 9: Final full verification

**Files:** none (verification only)

- [ ] **Step 1: Full verify**

```bash
cd web && bun run verify:all
```

Expected: PASS (type-check + lint clean).

- [ ] **Step 2: End-to-end manual pass**

With the C# API running (`cd api && dotnet run`) and `cd web && bun dev`:
1. Logged out: home shows hero + logo + "Get started"; header shows Login button.
2. Sign in as `user/user` → header shows username/role + Logout; home CTAs switch to Browse.
3. Visit Products and Sections → card rows render; confirm sky-blue price pills on products.
4. Log out → returns to `/login`; header reverts to Login button.
5. Sign in as `admin/admin` → same UI (no role-specific UI in scope).
6. Confirm the chat widget still opens and responds (unchanged).

- [ ] **Step 3: Confirm only `web/` changed**

```bash
git diff --name-only main... | grep -v '^web/\|^docs/\|^\.gitignore$' || echo "OK: only web/, docs/, .gitignore touched"
```

Expected: `OK: only web/, docs/, .gitignore touched` (no `api/` files).

---

## Self-Review (completed by plan author)

- **Spec coverage:** tokens+fonts (T2,T3) ✓; light-only (T2) ✓; shared header+logo (T1,T4) ✓; home (T5); login (T6); products w/ pill+states (T7); sections (T8); lean+lucide (T1) ✓; chat widget untouched ✓; verification (T9) ✓.
- **Placeholders:** none — every step has concrete code or commands.
- **Type consistency:** `getSession()`/`session.user.{username,role}` match existing `@/lib/auth`; `ProductResponse`/`SectionResponse` match existing types; CSS utility names (`bg-brand-ink`, `text-brand-spark`, `border-border-soft`, `bg-badge-bg`, `bg-canvas`, `font-display`) all map to tokens defined in T2's `@theme` block; `LogoutButton` import path matches its file.
