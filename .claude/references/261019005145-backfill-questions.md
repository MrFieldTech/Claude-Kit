# Session Reference: Answer What The First 1.14.0 Backfills Raised

**Task:** `backfill-questions`, DONE at close
**Repository:** MrFieldTech/Claude-Kit
**Developer:** GRM / MRFIELDTECH
**Written:** 2026-10-19 00:51:45 UTC
**Commits:** `049569e..51edf26` on `task/backfill-questions`
**Companion:** none

## Current State

Done. Release 1.15.0 lets a backfill of its own session's work run beside
others, recognises a backfill branch as `backfill-` and twelve digits, has
the BACKFILL RECOVERY PROMPT approve recreating the integration branch and
merging the backfill's own pull request, rebuilds interleaved task blocks
whole on a conflict, detaches after step 8 once the task branch is gone,
and reports a finished but unmerged task branch as a close perhaps still
running. Merged into `preview` and promoted to `main` at this close, at
MrFieldTech's request.

## Decisions

- A backfill of its own session's work skips one at a time; only one run
  first in a new session keeps it. MrFieldTech, 2026-10-19.
- Backfill step 1 matches `task/backfill-` and twelve digits only.
  MrFieldTech, 2026-10-19.
- The BACKFILL RECOVERY PROMPT approves, as item 8, recreating the
  integration branch and merging the backfill's own pull request into it.
  MrFieldTech, 2026-10-19.
- Two task blocks git interleaved are rebuilt whole and checked against
  the Format in `session-close`, not `check.sh`, which other repositories
  do not install. MrFieldTech, 2026-10-19, with the check named by
  GRM / MRFIELDTECH.
- `session-close` step 8 detaches at `origin/<target>` once the task
  branch is gone. MrFieldTech, 2026-10-19.
- A task branch finished on its branch but not on the base is reported as
  a close perhaps still running and is never offered for merging.
  MrFieldTech, 2026-10-19.

## Verified Facts

- Four backfills run at once in another repository each wrote one `-bf`
  reference for its own session and duplicated none. Source: four uploaded
  transcripts, placeholders under `.claude/imported/session-import/`
  ending `261018042553`.
- In those sessions auto mode denied recreating the integration branch by
  push and by the GitHub API, and once denied merging the session's own
  pull request. Source: the same transcripts.
- Merging the integration branch into each backfill branch conflicted in
  `TASKS.md`, where git interleaved two new task blocks around their shared
  field lines. Source: the same transcripts.
- `check.sh` is not installed by `kit.sh`, whose `KIT_DIRS` are
  `.claude/kit` and the two skills. Source: `.claude/kit/kit.sh` line 23.
- `bash check.sh` passed on `cbecebf`. Source: the command's output in
  this session.

## Exact Values

- Release: `1.15.0`
- Update slug: `kit-update-1-15-0`

## Artifacts

- `.claude/skills/session-open/SKILL.md`: step 3's unmerged-close bullet,
  step 5's conflict rule, Backfill step 1.
- `.claude/skills/session-close/SKILL.md`: step 8's conflict rule and
  detach, step 10's unmerged-close paragraph.
- `.claude/kit/HOUSE.md`: the interleaved-block sentence in When a merge
  conflicts.
- `README.md`: item 8 of the BACKFILL RECOVERY PROMPT, the update slug.
- `.claude/imported/session-import/`: four placeholders for the uploads.

## Gotchas

- `check.sh` fails on the status line until the release is committed.
- Backfill step 1 before 1.15.0 stopped on any `task/backfill-` branch,
  this task's own included.

## Flagged As Unverified

- Whether item 8 of the recovery prompt clears auto mode. Verified by: a
  backfill run with it that recreates the integration branch and merges.
- Whether the detach in step 8 quiets the end-of-turn hook. Verified by: a
  cloud close after a merge.

## Open Questions

None.

## Credentials

None.

## Subjects

### Claude-Kit backfill

**Slug:** `kit-backfill`
**Kind:** process

- From 1.15.0 backfills of their own sessions run side by side. Source:
  `.claude/skills/session-open/SKILL.md`, Backfill step 1.
- The recovery prompt approves the self-close's merge into the integration
  branch. Source: `README.md`, Backfill, item 8.
