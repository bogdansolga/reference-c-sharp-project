---
description: Resume work from a handoff summary created by /handoff:create
argument-hint: [optional path to a handoff file; defaults to the most recent]
---

Resume a previous session from a **handoff summary**. Target file: $ARGUMENTS

Steps:

1. Resolve the handoff file:
   - If `$ARGUMENTS` is a path, use it.
   - Otherwise pick the most recent file in `.claude/handoffs/`
     (`ls -t .claude/handoffs/*.md | head -1`). If none exist, stop and tell the user to run
     `/handoff:create` first.
2. **Read** the handoff file in full.
3. **Reconcile with reality** before doing anything — the repo may have changed since the
   handoff was written:
   - `git branch --show-current` (are we on the branch the handoff names?)
   - `git status --short` and `git log --oneline -5` (do "Files touched" / "State" still match?)
   - Spot-check the referenced `path:line` locations actually exist.
4. **Summarize back** to the user, in a few lines: the goal, what is done, and the **immediate
   next action** from the handoff's Next steps — flagging any drift you found in step 3.
5. Wait for confirmation only if there is drift or an open question that blocks progress;
   otherwise proceed with the next step, honoring this project's conventions (root + module
   `AGENTS.md`, the `scripts/` guardrails, verify before committing).

Trust the handoff for intent, but trust the live repo for current state — when they disagree,
the repo wins and you surface the mismatch.
