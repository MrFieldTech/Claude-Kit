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
sends it here, and only encrypted by the method that setting names.

## Decisions Made

None yet.

## Open Questions For <Owner>

None.

## Flagged As Unverified

None.
