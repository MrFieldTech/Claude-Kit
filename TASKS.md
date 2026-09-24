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
2. A scratch repository with a local remote goes through the first-run path
   by the skill text alone: settings proposed, state files written on a pushed
   task branch, the task worked, closed, parked for want of a pull request,
   and resumed from a fresh clone. **Done 2026-09-24, by hand.** A headless
   `claude` session was the plan, and the permission classifier refused to
   start one with its permissions bypassed. The walk found four defects in
   the skill text, all fixed: the default branch read with `origin/` still on
   it, a `CLAUDE.md` with no title, the kit check run before the kit is on
   the base, and a merge that created the integration branch before learning
   no pull request could be opened.
3. The repository the skills came from installs 1.0 in place of its own copies,
   and a fresh session there reports the same lines as before plus `Kit:`.

**Then the pilot.** The first other repository Devan chose takes the kit in a
fresh session he starts there. Every defect it finds is fixed here and
reinstalled.

**Decided by Devan, 2026-09-24, after the first build.** 1.0.0 reaches `main`
before the pilot, so the pilot installs by the command in `README.md`. No
permission rule is added for a headless `claude` session: the pilot and his
own sessions in real repositories are the fresh-session tests.

**Stopping point.** Items 1 and 2 are done, and item 3's install is done: the
repository the skills came from runs 1.0.0 from this branch. A review pass
after the walk fixed three more places a fresh session could misread. What
remains needs Devan: a fresh session in that repository for item 3's report,
the pilot, and his word on whether 1.0.0 reaches `main` before the pilot. Until
it does, the install command in `README.md` fails, because `main` holds only a
README.

### Pilot The Kit In A Second Repository

**Slug:** `first-pilot`
**Status:** TODO
**Opened:** 2026-09-24

Devan runs the first install outside the repository the skills came from, in a
fresh session on the second repository he chose. He says: "Install Claude-Kit
from https://github.com/MrFieldTech/Claude-Kit, then follow its session-open
skill." The first run should propose its Session Settings, ask about what it
cannot read, offer to remove the response-format section its existing
`CLAUDE.md` repeats from `HOUSE.md`, and push its first task branch.

Each defect the pilot finds is fixed here on this task's branch, released as a
patch version, and taken by `kit.sh update` in every repository that has the
kit. Record here what the pilot found, without naming the repository.

## Closed Tasks
