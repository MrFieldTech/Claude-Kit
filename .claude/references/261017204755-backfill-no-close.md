# Session Reference: Backfill Work That Ran No Kit Close

**Task:** `backfill-no-close`, DONE at close
**Repository:** MrFieldTech/Claude-Kit
**Developer:** GRM / MRFIELDTECH
**Written:** 2026-10-17 20:47:55 UTC
**Commits:** `054e960..d99a0e6` on `task/backfill-no-close`
**Companion:** none

## Current State

Done. Release 1.14.0 has `/session-open backfill` cover everything its
session did that no reference covers, names backfill references
`<yymmddhhmmss>-<slug>-bf.md`, has a session follow the `session-open` on
disk when it differs from the one it loaded, and adds the BACKFILL RECOVERY
PROMPT to `README.md`. Merged into `preview` and promoted to `main` at this
close, at MrFieldTech's request.

## Decisions

- A backfill in a session that has done work writes one reference for
  everything that session did that no reference covers: work before the
  kit, work outside any task, closes that wrote no reference, and a
  temporary session. Covered work is never written again. MrFieldTech,
  2026-10-17.
- A backfill reference is `<yymmddhhmmss>-<slug>-bf.md`: the task's slug
  when the work has exactly one, otherwise one the session chooses, cut at
  its end only when `<slug>-bf` passes the Task slug limit. MrFieldTech,
  2026-10-17.
- The time is the `handoff:` commit's for a past close, otherwise the last
  commit of the work that reached the default branch, or the time written.
  MrFieldTech, 2026-10-17.
- The developer always types `/session-open backfill` first, and pastes the
  BACKFILL RECOVERY PROMPT from the kit's `README.md` only when the session
  does not know what to do. MrFieldTech, 2026-10-17.
- A session whose loaded `session-open` differs from the one on disk after
  step 2 follows the disk version. GRM / MRFIELDTECH, 2026-10-17.

## Verified Facts

- Claude Code registers skills from the checkout when a session starts, so
  a session whose checkout predates the kit has no `/session-open`. Source:
  three uploaded transcripts from sessions in another repository, each
  saying the command was not installed.
- 1.13.0's backfill, run in a session whose work predated the kit, reported
  nothing to cover, as its rules then said. Source: a fourth uploaded
  transcript.
- `bash check.sh` passed on `f4f1f49` and on `d99a0e6`. Source: the
  command's output in this session.

## Exact Values

- Release: `1.14.0`
- Update slug: `kit-update-1-14-0`

## Artifacts

- `.claude/kit/references.md`, Backfilling: what a backfill covers, Past
  closes, Its name, From a conversation.
- `.claude/skills/session-open/SKILL.md`: step 2's rule for a newer skill
  on disk, and Backfill steps 2 to 4.
- `.claude/kit/HOUSE.md`: the backfill sentence under Sessions and branches.
- `README.md`: a Backfill section holding the BACKFILL RECOVERY PROMPT.
- `.claude/imported/session-import/`: four placeholders for the uploaded
  transcripts.

## Gotchas

- `check.sh` installs from `HEAD`, so run before the release is committed
  it fails on the status line. Commit first.
- Uploads sat under `/root/.claude/uploads/` with eight hex digits and a
  hyphen in front of the original name.

## Flagged As Unverified

- The recovery prompt has not been pasted into an old session. Verified by:
  pasting it into a session whose checkout predates the kit.
- No backfill has run under 1.14.0. Verified by: `/session-open backfill`
  in a session that did work with no close.

## Open Questions

- Should `grilling.md` have each option show, by a concrete example, what
  the kit would then do? MrFieldTech can answer.

## Credentials

None.

## Subjects

### Claude-Kit backfill

**Slug:** `kit-backfill`
**Kind:** process

- From 1.14.0 a backfill covers everything its session did that no
  reference covers. Source: `.claude/kit/references.md`, Backfilling.
- A session the skill cannot reach is recovered by the BACKFILL RECOVERY
  PROMPT. Source: `README.md`, Backfill.
