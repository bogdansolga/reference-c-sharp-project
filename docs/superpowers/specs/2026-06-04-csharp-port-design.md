# reference-c-sharp-project — Port & Course-Showcase Design

**Date:** 2026-06-04
**Status:** DRAFT — awaiting sign-off
**Source of truth:** `_reference/reference-typescript-project` (the lighter reference; port mirrors it, not the heavier Spring Boot port)

---

## 1. Goal & constraints

Port the TypeScript reference into an idiomatic **.NET 8** project at `_reference/reference-c-sharp-project` that:

1. **Showcases every course part** (Foundations → Daily Workflow → Extensibility → Power Tools → Large-Codebase Appendix). Each part must have a concrete artifact to demo *inside this repo*.
2. **Reuses to the max from the TS project** (explicit instruction — it is the lighter, cleaner reference). Frontend is reused near-verbatim; only the backend is rewritten in C#.
3. **Ports the git hooks + their checks faithfully** — they are the headline "deterministic guardrails" story and the strongest answer to the audience's "not production-grade / over-generation" pain.

Decided already: **.NET 8 (LTS)** · **port the Next.js UI** · **AI chat via Claude/Anthropic**.
Open decision: **chat tier** (§7).

---

## 2. Target architecture — polyglot monorepo

```
reference-c-sharp-project/
├── api/                         # ASP.NET Core 8 — the C# port (all domain logic)
│   ├── Api.csproj
│   ├── Program.cs               # Minimal API host, DI, cookie auth, EnsureCreated+seed
│   ├── Endpoints/               # ≈ TS route handlers  (product, section, auth, chat?)
│   ├── Services/                # ≈ TS lib/services      (ProductService, SectionService)
│   ├── Repositories/            # ≈ TS lib/repositories  (EF Core data access only)
│   ├── Domain/                  # entities + domain errors (NotFoundError, ValidationError)
│   ├── Validation/              # FluentValidation validators (≈ TS lib/types Zod)
│   ├── Data/                    # AppDbContext (EF Core) + Seeder        (≈ TS lib/db)
│   ├── Http/                    # error handler, HTTP status, messages   (≈ TS lib/core/http)
│   └── Auth/                    # cookie session helpers                 (≈ TS lib/auth)
├── web/                         # REUSED Next.js frontend (copied from TS project, backend stripped)
│   ├── src/app/                 # pages + login + product/section pages  (verbatim)
│   ├── src/components/          # chat-widget.tsx                        (verbatim)
│   └── next.config.ts           # rewrites /api/* → http://localhost:5099  (the only real change)
├── scripts/                     # PORTED guardrails (config-driven, retargeted to C#)
│   ├── check-architecture.sh
│   ├── check-validators.sh      # (TS check-schemas.sh, renamed for C#)
│   ├── check-deep-architecture.sh
│   ├── arch-checks.conf         # patterns rewritten for .cs / using-directives
│   └── git-hooks/{pre-commit,pre-push,install.sh}   # stack-aware (C# + TS)
├── .claude/                     # Part 3/4 showcase: commands, a skill, settings hooks, .mcp.json
├── CLAUDE.md                    # layered conventions (mirrors TS CLAUDE.md, C# idioms)
├── README.md
└── docs/                        # ai-for-coding.md (C# exercise ladder), porting notes
```

**Why this shape:** the browser sees a single origin (`web` on :3000); `next.config` rewrites `/api/*` to the C# backend (:5099), so cookie auth + the existing `fetch` calls in the reused pages work **unchanged**. This is the maximum-reuse path and a realistic enterprise "TS front / .NET back" split.

---

## 3. Reuse strategy — what is copied vs rewritten

| From TS project | Action | Notes |
|---|---|---|
| `src/app/*` pages, `layout.tsx`, `login`, `product`, `section`, `logout-button` | **Copy verbatim** into `web/` | They already fetch `/api/v1/*` with cookie forwarding |
| `src/components/chat-widget.tsx`, `globals.css`, `favicon` | **Copy verbatim** | |
| `next.config`, `package.json`, `biome.jsonc`, `tsconfig.json` (web only) | **Copy + trim** | add `/api/*` rewrite; drop server-only deps (drizzle, better-sqlite3) |
| `src/lib/**` (services, repos, db, auth, types, http) | **Rewrite in C#** (`api/`) | the actual port |
| `src/app/api/**` route handlers | **Rewrite as `api/Endpoints/`** | same REST contract & status codes |
| `src/prompts/chat-system.md` | **Copy** | reused by whichever tier owns chat |
| `scripts/` guardrails | **Port** (§6) | preserve behavior, retarget patterns |
| `CLAUDE.md`, `docs/ai-for-coding.md` | **Adapt** | C# paths, `dotnet` commands, fixed stale paths |

---

## 4. Stack mapping (all backend deps via NuGet — only the SDK via `nb`)

| TS | C# (.NET 8) |
|---|---|
| Bun runtime | .NET 8 SDK — `nb install --cask dotnet-sdk@8` (only `nb` dep) |
| Next.js API routes | ASP.NET Core Minimal API endpoints |
| better-sqlite3 + Drizzle | `Microsoft.EntityFrameworkCore.Sqlite` (bundles native SQLite) |
| Zod (`lib/types`) | `FluentValidation` |
| cookie session (`getSession`) | ASP.NET Core cookie authentication |
| `NotFoundError`/`ValidationError` + `handleError()` | domain exceptions + exception-handler middleware (name→status, mirrors TS) |
| Vitest | xUnit + FluentAssertions |
| Biome | `dotnet format` (+ Roslyn analyzers, `.editorconfig`) |
| `instrumentation.ts` seed-on-startup | `db.Database.EnsureCreated()` + `Seeder` in `Program.cs` |
| Vercel AI SDK (OpenAI) | Anthropic — see §7 |

Test users preserved: `user/user` (USER), `admin/admin` (ADMIN).

---

## 5. Layer model (identical semantics, C# names)

```
Endpoints  → Services → Repositories → EF Core (AppDbContext) → SQLite
(HTTP)       (logic)    (data only)
```
- **Endpoints**: HTTP only; validate (FluentValidation), call services, map exceptions.
- **Services**: business logic; throw **domain** exceptions (never generic `Exception`).
- **Repositories**: EF Core queries only; no HTTP/ASP.NET `using`.
- **Validation lives in `api/Validation/`**, never inline in endpoints/services (the schema-location rule, ported).

---

## 6. Guardrail port (faithful — behavior preserved, patterns retargeted)

The checks are **config-driven** (`arch-checks.conf` = regex over file paths + forbidden imports). Porting = rewrite the patterns for `.cs` + `using` directives; the script skeletons and hook orchestration stay.

### 6.1 `arch-checks.conf` → C#

| TS pattern | C# pattern |
|---|---|
| `PAGE_PATTERN src/app/.*page\.tsx$` | `web/.*page\.tsx$` (kept — frontend still checked) |
| `ROUTE_PATTERN .../route\.ts$` | `ENDPOINT_PATTERN api/Endpoints/.*\.cs$` |
| `SERVICE_PATTERN lib/services/.*\.ts$` | `api/Services/.*\.cs$` |
| `ROUTE_FORBIDDEN @/lib/repositories @/lib/core/db` | endpoints forbid `using *.Repositories`, `using *.Data` |
| `SERVICE_FORBIDDEN @/lib/core/db` | services forbid `using *.Data` (no direct DbContext) |
| `REPO_LAYER_PATH lib/repositories` + `HTTP_MODULE_PATH @/lib/core/http` | `api/Repositories` must not `using Microsoft.AspNetCore.*` / `api/Http` |
| `HOF_FUNCTION withErrorHandling`, `AUTH_FUNCTION withAuth` | C# equivalents: `[Authorize]` attribute / endpoint filter names |
| `SERVICES_PATH` + generic `throw new Error(` | `api/Services` must not `throw new Exception(` (use domain exceptions) |
| `REPO_IMPORT_PATTERN @/lib/repositories` (routes) | endpoints must not `using *.Repositories` |
| schema check: `import { z } from "zod"` in routes/services | validators check: inline `: AbstractValidator` / `RuleFor` in endpoints/services |

### 6.2 Hooks (stack-aware)

`pre-commit` / `pre-push` keep their structure (numbered checks, parallel pre-push, file-size warnings, `--no-verify` bypass, CI skip) but become **polyglot**:
- Staged `*.cs` → `dotnet build` (type), `dotnet format --verify-no-changes` (lint), `dotnet test` (pre-push), + the C# arch checks.
- Staged `*.ts/*.tsx` (web/) → existing Biome + `tsc` path.
- File-size limits retargeted: `*Service.cs`→500, `*.tsx`→400, other→300 (same numbers).
- `install.sh` copies hooks into `.git/hooks` and checks into `scripts/` (unchanged logic).

> This polyglot hook is itself a **Part 3 teaching artifact**: one guardrail set enforcing two stacks.

---

## 7. OPEN DECISION — chat tier

The reused `chat-widget.tsx` uses Vercel AI SDK `useChat` ↔ the AI-SDK "UI-message-stream" SSE protocol.

- **Option B (recommended, given "reuse-max / lighter"):** chat stays in `web/` as a thin Next route, provider flipped **OpenAI → Anthropic** (~5-line change). C# owns `/api/v1/*` + auth. Lightest; widget + transport reused unchanged. Part 4 demos MCP/LSP against the C# API (chat-in-C# not needed for Part 4).
- **Option A (purist stretch):** C# owns `/api/chat`, emitting the AI-SDK stream protocol from Claude tokens (or swap the widget to plain Anthropic SSE). Truer "all-C# backend"; more protocol work. Keep as a **documented Part 4 stretch demo**.

**Proposal:** ship **B** for v1, document **A** as an optional deep-dive. Confirm or override.

---

## 8. Course-part showcase map (what each part demos in this repo)

| Part | Demo artifact in reference-c-sharp-project |
|---|---|
| **P1 Foundations** | Replay a real Analyze→Plan→Execute session against this repo (e.g. add a search endpoint); HITL diff review; the config-protection PreToolUse hook blocking a write |
| **P2 Daily Workflow** | `CLAUDE.md` (layered conventions, commands table, "Do NOT" list); drive `docs/ai-for-coding.md` C# exercises 1–4 |
| **P3 Extensibility** | **Guardrails headline:** the ported git hooks + `check-*` scripts the agent cannot skip; `.claude/` commands + a project skill ("add an endpoint following the layered pattern"); a `settings.json` PostToolUse hook running `dotnet format` on edited `.cs` |
| **P4 Power Tools** | `.mcp.json` (Postgres/GitHub) against the C# API; LSP on the .NET project (OmniSharp/C# Dev Kit) — symbol nav; install a plugin; (stretch) move chat into C# |
| **Appendix Scale** | Run the lean/layered-CLAUDE.md + harness-inventory audit against this repo as the worked example |

Cross-stack teaching value: the **same `arch-checks.conf` translated TS→C#** is the live proof that guardrails are stack-portable — the headline reassurance for the mostly-.NET audience.

---

## 9. Local run (recap)

```bash
nb install --cask dotnet-sdk@8          # only system dep (admin pkg — run via ! prefix)
# backend
cd api && dotnet restore && dotnet run    # Kestrel :5099, EnsureCreated + seed on startup
# frontend
cd web && bun install && bun dev          # Next.js :3000 → proxies /api/* to :5099
```
Chat needs `ANTHROPIC_API_KEY` (env / `.env`). No migration step (EnsureCreated). Optional: `nb install sqlite` (inspect db), `dotnet tool install -g dotnet-ef` (only if migrations chosen over EnsureCreated).

---

## 10. Build order (phases for sign-off)

1. **Scaffold** `api/` (.NET 8 Minimal API) + DI + cookie auth + `AppDbContext` + EnsureCreated/seed; `git init`.
2. **Domain port:** Domain entities, Repositories, Services (domain exceptions), Validation, Http error handler — products + sections + auth. xUnit tests mirroring the Vitest suite.
3. **Frontend reuse:** copy `web/`, trim server deps, add `/api/*` rewrite; verify pages + login work end-to-end against `api/`.
4. **Chat:** per §7 decision.
5. **Guardrails port:** scripts + stack-aware hooks + `arch-checks.conf`; run them green.
6. **Showcase layer:** `CLAUDE.md`, `.claude/` (commands/skill/hooks/.mcp.json), `docs/ai-for-coding.md` (C#).
7. **Course wiring:** update `build-training-part*.sh` slide content + the outline `.md` to name this repo per §8.

---

## 11. Open items for sign-off

1. **Chat tier** — confirm **B (recommended)** vs A (§7).
2. **Endpoints style** — Minimal API (recommended, lighter) vs Controllers (more familiar to enterprise .NET). 
3. **DB init** — EnsureCreated-on-startup (recommended, mirrors TS, zero run steps) vs EF migrations.
4. Should the port land **incrementally with commits per phase** (recommended) or as one batch?
