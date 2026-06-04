---
command: git:catchup
description: Identify what was worked on in previous session(s)
argument-hint: "[depth] — how far back to look (commit count, default 10)"
---

# Catchup

`$ARGUMENTS` optionally sets how far back to look. Interpret it as the number
of commits to inspect (e.g. `5`, `20`). If empty or not a number, default to
**10**. Call the resolved value `<N>` below.

Inspect with one bash call (substitute `<N>`):

```
git status -sb && echo --- && git log -<N> --oneline && echo --- && git log -3 --stat
```

If status shows uncommitted changes, follow with `git diff --stat HEAD`
(filenames + line counts). Only request full `git diff` when the user wants
specific change details — full diffs can be huge.

Summarize: what was being worked on, anything in-flight, apparent blockers.
Ask only if the changes don't form a coherent story.
