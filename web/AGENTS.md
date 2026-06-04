# web — AGENTS.md

Guidance for AI coding agents working in the **`web/`** module. See the
[root AGENTS.md](../AGENTS.md) for the project overview.

Next.js (App Router) frontend, reused as-is from the TS reference. It renders the product/section
lists server-side from the C# API and hosts the chat widget.

## Run / verify

```bash
cd web && npm run dev         # http://localhost:3000 (Turbopack); bun dev also works
npm run build                 # production build
npm run verify:all            # type-check + lint (Biome) — run before committing
npm run format                # biome format --write
```

Prerequisites: a Node package manager (**npm** default, **Bun** optional via `PM=bun`) and
`ANTHROPIC_API_KEY` for the chat widget. Copy `.env.example` to `.env`.

## How it talks to the backend

`next.config.ts` rewrites proxy backend calls to the C# API (`API_URL`, default
`http://localhost:5099`):

- `/api/v1/*` and `/api/auth/*` → proxied to the C# API.
- `/api/chat` → **stays local** to Next, served by `src/app/api/chat/route.ts` on
  Anthropic/Claude via the Vercel AI SDK (system prompt in `src/prompts/chat-system.md`).

## Layout

- `src/app/` — routes: `page.tsx` (home), `login/`, `product/`, `section/`, `api/chat/route.ts`.
- `src/components/chat-widget.tsx` — the Claude-backed chat UI.
- `src/lib/auth/` — session helpers; `src/lib/types/` — `product`/`section` types.
- `src/styles/globals.css` — Tailwind. Tooling: `biome.jsonc`, `tsconfig.json`.

## Conventions

- TypeScript strict; Biome for lint + format (no ESLint/Prettier).
- Keep types in `src/lib/types/` aligned with the C# DTOs (camelCase JSON).
- Don't hardcode the backend host — use the proxy rewrites / `API_URL`.

## Do NOT

- Reimplement `/api/v1` or `/api/auth` logic here — those are the C# API's responsibility.
- Commit `.env` or secrets — only `.env.example` is tracked.
