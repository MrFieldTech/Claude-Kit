# Session Reference: Hold The Task Block Fields To One Format In check.sh

**Task:** `check-block-fields`, DONE at close
**Repository:** MrFieldTech/Claude-Kit
**Developer:** GRM / MRFIELDTECH
**Written:** 2026-10-16 21:31:16 UTC
**Commits:** `85e0cb5..68b60a4` on `task/check-block-fields`
**Companion:** none

## Current State

Done. Release 1.9.0 adds `check.sh` section 4, which holds every fenced
task field block and holder line to `.claude/kit/templates/TASKS.md`,
and swaps `HOUSE.md`'s holder pair to the template's order. Merged into
`preview` at this close.

## Decisions

- The check is strict: a fenced field block matches the template's line
  for line, placeholders included. MrFieldTech, 2026-10-16.
- The check covers holder lines as well as the field block. MrFieldTech,
  2026-10-16.
- The check holds all three copies to the template, this repository's
  `TASKS.md` included, reading only its fenced examples above Open Tasks.
  MrFieldTech, 2026-10-16.
- Copies of a template's details never differ, even by order, so
  `HOUSE.md`'s holder pair was swapped and the task became a release.
  MrFieldTech, 2026-10-16.

## Verified Facts

- Before this release the field block was identical in the template,
  `session-close`'s Format and this repository's `TASKS.md`; only
  `HOUSE.md`'s holder pair differed, in order. Source: the new check,
  failing on `HOUSE.md` alone before the swap.
- A dropped field, a changed placeholder, a changed holder line and the
  old `HOUSE.md` order each make `bash check.sh` fail. Source: each
  edit made by hand and the check run, 2026-10-16.
- `bash check.sh` passes on `d83bccf`. Source: the command, run after
  that commit.

## Exact Values

- Release: `1.9.0`
- Update slug: `kit-update-1-9-0`

## Artifacts

- `check.sh` section 4, the format check; sections after it renumbered
  5 to 8.
- `.claude/kit/HOUSE.md`, Developers: holder example now `INACTIVE`
  above `ACTIVE`.
- `VERSION`, `CHANGELOG.md` and `README.md` for 1.9.0.

## Gotchas

- `session-close`'s Format section holds a fenced `TASKS.md` skeleton
  with an `## Open Tasks` line, so cutting every file at that heading
  hid its field block from the check; only files named `TASKS.md` are
  cut there.
- Fenced examples in kit-owned files use other bold labels, such as
  `**Purpose:**` and `**Reconstructed:**`, so the check matches only
  the template's own field labels.
- `check.sh` section 6 installs from `HEAD`, so a release fails it
  until committed.

## Flagged As Unverified

None.

## Open Questions

- Should `grilling.md` have a question carried from an earlier session
  rewritten before it is asked? MrFieldTech can answer.

## Credentials

None.

## Subjects

### Claude-Kit check.sh

**Slug:** `claude-kit-check`
**Kind:** process

- Section 4 compares fenced examples in `.claude/kit`,
  `.claude/skills/session-open`, `.claude/skills/session-close` and
  `TASKS.md` against `.claude/kit/templates/TASKS.md`. Source:
  `check.sh`.
