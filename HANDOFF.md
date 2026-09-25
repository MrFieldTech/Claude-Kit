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
| 2026-09-25 | `first-pilot`, BLOCKED, merged into `preview` and then `main` at Devan's request: the first pilot attempt was blocked before the install, and the install prompt in `README.md` was fixed for both causes | `f82f24f..76f1139` |
| 2026-09-24 | `release-1-0`, DONE, merged into `preview` and then `main` at Devan's request: 1.0.0 built, checked, walked through a scratch repository, and installed in the repository the skills came from. `first-pilot` queued | `763033b..28fb6c4` |

## Blocked On

| Task | Waiting on |
|---|---|
| `first-pilot` | Devan running the pilot again in a fresh session, with the install prompt from `README.md` word for word |

## Credentials In Transit

None. A value is held here only when the Credentials setting in `CLAUDE.md`
sends it here, and in this repository it never does.

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
- **1.0.0 reached `main` before the pilot.** Devan, 2026-09-24, so the pilot
  installs by the command in `README.md` rather than from a task branch.
- **No permission rule for a headless `claude` session.** Devan, 2026-09-24.
  The pilot and his own sessions in real repositories are the fresh-session
  tests.
- **Files here are written as if the repository were public.** It was asked
  for as public and created private. Nothing the kit installs names a
  project, so making it public later needs no cleanup first.

## Open Questions For Devan

1. Should this repository stay private or be made public, as it was asked for?
   While it is private, a session in another repository needs it attached
   before it can install or update the kit, and `kit.sh status` reads `source
   unreachable` in any session without that access.

## Flagged As Unverified

**No fresh session has run the kit yet.** The first-run path was walked by
hand, by the session that wrote it, which knows what the text means to say. A
fresh session reads only what the text does say. The pilot is the first real
test.

**Whether the new install prompt clears auto mode's classifier.** It names the
writes into `.claude/` and `CLAUDE.md` as wanted, which is what the
`[Self-Modification]` rule in `claude auto-mode defaults` asks for, but no
session has been given it yet. The next pilot attempt verifies it.

**Whether Accept edits mode lets a cloud session's owner approve the install.**
The permission-modes documentation says a cloud session's Accept edits mode is
`default` mode, where a shell command outside the read-only set prompts.
Nobody has tried it. A pilot that falls back to it verifies it.

**Whether a skill installed partway through a session is listed before the
next session starts.** The install prompt in `README.md` says to follow the
skill rather than run `/session-open`, so the first run works either way.

**The house rules load by import.** Confirmed in a headless session on
2026-09-24, with no approval prompt. Not yet seen in an interactive session.

**The repository the skills came from has not yet opened a session on the
kit.** Its next `/session-open` should print a `Kit:` line. That report is
item 3 of `release-1-0`.

**Whether GitHub deletes merged branches here.** It did not: `task/release-1-0`
was still on the remote after it merged, with no commit `main` lacks. Devan
turned Automatically delete head branches on on 2026-09-25 and is deleting that
branch himself. Whether `task/first-pilot` and `preview` go when their pull
requests merge is in the close report for 2026-09-25, and the next
`/session-open` sees it in `git branch -r`.
