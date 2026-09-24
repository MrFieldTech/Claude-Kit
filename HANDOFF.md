# Session Handoff

## Purpose

The state above any one task that a fresh session needs. `session-close` edits
this file in place at the end of every session and `session-open` reads it at
the start of the next, so a session with no memory of the last one picks up
from committed files alone. Where each task stopped is in its own block in
`TASKS.md`, not here, because sessions on different tasks can close into this
file at the same time.

## Session Log

| Date | Tasks touched | Work commits |
|---|---|---|

## Blocked On

None.

## Credentials In Transit

None. A value is held here only when the Credentials setting in `CLAUDE.md`
sends it here, and in this public repository it never does.

## Decisions Made

- **The kit is vendored, not a plugin and not account-level skills.** Devan,
  2026-09-24. Each repository holds a pinned copy, so it resumes from
  committed files alone, a kit change reaches it as a reviewable diff, and the
  command names stay `/session-open` and `/session-close`. A plugin cannot
  carry `CLAUDE.md` and would put the protocol governing a repository outside
  it. Skills held on an account sit outside git and go stale unseen.
- **The house rules are imported by `CLAUDE.md`, not carried in a skill.** A
  skill's text loads only when invoked and can be compacted away, and the
  response rules govern every turn. The import was confirmed to load in a
  headless session on 2026-09-24.
- **The integration branch is a per-repository setting, `preview` by
  default.** Devan, 2026-09-24. The rule that the default branch moves only
  when the owner asks then holds everywhere unless a repository opts out.

## Open Questions For Devan

None.

## Flagged As Unverified

**No fresh session has run the kit yet.** The first-run path was walked by
hand, by the session that wrote it, which knows what the text means to say. A
fresh session reads only what the text does say. The pilot is the first real
test.

**Whether a skill installed partway through a session is listed before the
next session starts.** The install prompt in `README.md` says to follow the
skill rather than run `/session-open`, so the first run works either way.

**The house rules load by import.** Confirmed in a headless session on
2026-09-24, with no approval prompt. Not yet seen in an interactive session.
