---
description: Summarize the current conversation into a handoff file so it can be resumed in a new session
argument-hint: [optional short label for the handoff]
---

Create a **handoff summary** of this conversation so a fresh session (this or another agentic
CLI) can resume the work with no loss of context. Optional label for the file: $ARGUMENTS

Steps:

1. Ensure the directory exists: `mkdir -p .claude/handoffs`.
2. Pick a filename `.claude/handoffs/<UTC-timestamp>-<slug>.md` where the timestamp is
   `YYYY-MM-DD-HHMM` (use `date -u +%Y-%m-%d-%H%M`) and `<slug>` is a short kebab-case label
   derived from `$ARGUMENTS` or, if empty, from the main task of this session.
3. Write the file with these sections — be concrete and specific, not generic:

   ```markdown
   # Handoff — <task title>
   _Created: <UTC timestamp> · Branch: <git branch> · Base: <git base/main>_

   ## Goal
   The objective in 1–3 sentences. Why this work is happening.

   ## State / progress
   What is DONE vs IN PROGRESS vs NOT STARTED. Be honest about what is verified
   (tests run, commands passed) vs assumed.

   ## Files touched
   Bullet list of `path:line` references with a one-line note on each change.
   Include uncommitted changes (`git status --short`).

   ## Key decisions
   Choices made and the reasoning, so they are not relitigated. Note rejected options.

   ## Next steps
   Ordered, actionable TODO list for whoever resumes. Lead with the immediate next action.

   ## Verify
   The exact commands to confirm the work (e.g. `dotnet build && dotnet test`,
   `cd web && npm run verify:all`) and their last known result.

   ## Open questions / risks
   Anything unresolved, blocked, or needing a human decision.
   ```

4. Capture live context for accuracy: run `git status --short` and `git branch --show-current`,
   and reference the actual files changed this session.
5. Report the written path and a 2–3 line preview. Do **not** commit the file — handoffs are
   session scratch (suggest adding `.claude/handoffs/` to `.gitignore` if it is tracked).

Keep it tight and high-signal: enough for a cold start, no filler.
