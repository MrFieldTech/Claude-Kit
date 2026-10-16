# Session Reference: Claim A New Task's Branch Before Grilling It

**Task:** `grill-position-diff`, DONE at close
**Repository:** MrFieldTech/Claude-Kit
**Developer:** GRM / MRFIELDTECH
**Written:** 2026-10-16 16:03:52 UTC
**Commits:** `df78d4f..6580c0f` on `task/grill-position-diff`
**Companion:** none

## Current State

Release 1.8.0 is built and `bash check.sh` passes on it. This close merges
it into `preview` and then `main`.

## Decisions

- A new task is claimed on its branch first, then grilled there, each round
  written into its block and pushed before it is asked. GRM / MRFIELDTECH,
  2026-10-16.
- An answered question leaves the block and becomes a decision, in the
  owner's sense; the block keeps no transcript. GRM / MRFIELDTECH,
  2026-10-16.
- A task grilling drops, or finds duplicating another, closes `DONE` with a
  `Dropped:` line and merges; a misleading slug stays unless the owner asks.
  GRM / MRFIELDTECH, 2026-10-16.
- With work described and no slug, the session offers any open task that
  covers it, else claims under a slug it chooses. GRM / MRFIELDTECH,
  2026-10-16.
- Grilling questions stay in the block; `HANDOFF.md` takes one only when the
  task blocks on it or closes `DONE` with it open. GRM / MRFIELDTECH,
  2026-10-16.

## Verified Facts

- Grilling came before the claim only because 1.3.0 asked for it "before a
  task's block is written" and step 5 writes the block in the claim's
  commit. Source: the `workflow-practices` block in `TASKS.md`.
- `session-open` step 4 case e already lists task branches and open tasks
  and asks when nothing is named. Source:
  `.claude/skills/session-open/SKILL.md`, step 4.
- The task's block fields are written out in the `TASKS.md` template, this
  repository's `TASKS.md` and `session-close`'s Format. Source: `grep -rn
  'Closed:\*\* <'`.

## Exact Values

- README update slug: `kit-update-1-8-0`
- New block field: `**Dropped:** <why the work was not done, only when dropped>`

## Artifacts

- `.claude/skills/session-open/SKILL.md`, `.claude/kit/practices/grilling.md`,
  `.claude/kit/HOUSE.md`, `.claude/skills/session-close/SKILL.md`,
  `.claude/kit/templates/TASKS.md`: changed for 1.8.0.

## Gotchas

- `check.sh` does not compare the block fields across their three copies,
  so a new field can reach one and miss another.

## Flagged As Unverified

- 1.8.0's `session-open` has not run from the skill. Verified by: the next
  new task's open.

## Open Questions

- Should `check.sh` hold the block fields in `session-close` to the
  template? MrFieldTech can answer.

## Credentials

None.

## Subjects

### Claude-Kit grilling

**Slug:** `kit-grilling`
**Kind:** process

- From 1.8.0 a new task's branch is claimed before grilling, and every round
  is in its block before it is asked. Source: `grilling.md`, Rounds.
