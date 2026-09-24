# Tasks

## Purpose

The work queue for this repository and the source of truth for what remains.
Each task's block holds its full specification, and an open task's block holds
exactly where it stopped. `session-close` writes this file and `session-open`
reads it. `.claude/kit/HOUSE.md` holds the rules.

## How Tasks Are Worked

Every task is worked on its own branch, `task/<task-slug>`, named after its
slug. `/session-open <task-slug>` resumes a task, or starts a new one when the
slug names no task. With no slug, `session-open` lists the parked task branches
and the queued tasks and asks what to work on. Open Tasks are in the order they
are to be worked. Sessions on different tasks can run at the same time.

At close, a finished task merges by pull request and GitHub deletes its branch.
A task stopped partway stays `ACTIVE` and parked on its branch.

Tasks carry a slug and never a number, so a task can be reordered, split, or
closed without disturbing any reference to it. Task slugs are unique and
permanent and name the task's branch.

| Marker | Meaning |
|---|---|
| `TODO` | Not started, and has no branch |
| `ACTIVE` | In progress on its branch, or parked there between sessions |
| `BLOCKED` | Cannot proceed, and its `Blocked:` line says what would unblock it. A task whose remaining work only the owner can do stays here rather than leaving the queue |
| `DONE` | Finished, merged, and moved to Closed Tasks |

Each task's heading is its title, and directly under it:

```markdown
**Slug:** `<task-slug>`
**Status:** TODO | ACTIVE | BLOCKED | DONE
**Opened:** <YYYY-MM-DD>
**Blocked:** <what would unblock it, only when BLOCKED>
**Closed:** <YYYY-MM-DD, only when DONE>
```

Then the detail block, as prose.

## Open Tasks

### Build The First Release

**Slug:** `release-1-0`
**Status:** ACTIVE
**Opened:** 2026-09-24

Devan, 2026-09-24: the session skills he runs in one repository should work in
any of his repositories. A repository that has never used them gets a
first-run path that builds its state files, and the rules for how Claude works
and answers are shared the same way. This repository is the single source,
installed into each repository as a pinned copy.

**What 1.0 is.** `HOUSE.md`, the two skills, `kit.sh`, `todo_sweep.py` and the
templates, drawn from the existing skills with every value specific to one
repository moved into Session Settings. `check.sh` and the CI workflow guard
the release.

**Verification before it merges.**

1. `bash check.sh` passes.
2. A headless session in a scratch repository with a local remote runs the
   first-run path from the skill text alone: it proposes settings, asks, and
   writes the state files on a pushed task branch. A second headless session
   resumes that task by its slug.
3. The repository the skills came from installs 1.0 in place of its own copies,
   and a fresh session there reports the same lines as before plus `Kit:`.

**Then the pilot.** The first other repository Devan chose takes the kit in a
fresh session he starts there. Every defect it finds is fixed here and
reinstalled.

**Stopping point.** The files for 1.0 are written. Next: run `bash check.sh`,
then verification item 2.

## Closed Tasks
