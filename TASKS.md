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

### Pilot The Kit In A Second Repository

**Slug:** `first-pilot`
**Status:** TODO
**Opened:** 2026-09-24

Devan runs the first install outside the repository the skills came from, in a
fresh session on the second repository he chose, with Claude-Kit attached to
the session because it is private. He says: "Install Claude-Kit from
https://github.com/MrFieldTech/Claude-Kit, then follow its session-open
skill." The first run should propose its Session Settings, ask about what it
cannot read, offer to remove the response-format section its existing
`CLAUDE.md` repeats from `HOUSE.md`, and push its first task branch.

Each defect the pilot finds is fixed here on this task's branch, released as a
patch version, and taken by `kit.sh update` in every repository that has the
kit. Record here what the pilot found, without naming the repository.

## Closed Tasks

### Build The First Release

**Slug:** `release-1-0`
**Status:** DONE
**Opened:** 2026-09-24
**Closed:** 2026-09-24

Devan, 2026-09-24: the session skills he runs in one repository should work in
any of his repositories. A repository that has never used them gets a
first-run path that builds its state files, and the rules for how Claude works
and answers are shared the same way. This repository is the single source,
installed into each repository as a pinned copy.

**What 1.0.0 is.** `HOUSE.md`, the two skills, `kit.sh`, `todo_sweep.py` and
the templates, drawn from the existing skills with every value specific to one
repository moved into Session Settings. `check.sh` and the CI workflow guard a
release.

**How it was verified.**

1. `bash check.sh` passes, and each of its guards was made to fail on purpose
   to prove it can: a project term, an em dash, an unrecorded version, a skill
   the model could invoke, a stale `TODO.md`, and a broken `kit.sh`.
2. A scratch repository with a local remote went through the first-run path by
   the skill text alone: settings proposed, state files written on a pushed
   task branch, the task worked, closed, parked for want of a pull request,
   and resumed from a fresh clone. It was walked by hand, because the
   permission classifier refused to start a headless `claude` session with its
   permissions bypassed. The walk found four defects in the skill text: the
   default branch read with `origin/` still on it, a `CLAUDE.md` with no
   title, the kit check run before the kit is on the base, and a merge that
   created the integration branch before learning no pull request could be
   opened. A review pass after it found three more: the first task falling into
   the case that stops to ask, two credential rules that overlapped, and a
   pending combined status read as a running check. All seven are fixed.
3. The repository the skills came from installed 1.0.0 in place of its own
   copies. A fresh session there has not run it yet; `HANDOFF.md` flags it.

**Decided by Devan, 2026-09-24.** 1.0.0 reaches `main` before the pilot, so the
pilot installs by the command in `README.md`. No permission rule is added for a
headless `claude` session: the pilot and his own sessions in real repositories
are the fresh-session tests. At close he asked for everything to reach `main`.

The pilot is `first-pilot`.
