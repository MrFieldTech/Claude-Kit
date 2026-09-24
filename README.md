# Claude-Kit

A session protocol and a set of house rules for Claude Code, installed into
each repository that uses them as a pinned copy.

Each session in a repository that uses the kit opens with `/session-open` and
closes with `/session-close`. A session resumes from committed files alone.
Each task is worked on its own branch, so sessions on different tasks can run
at the same time. A task stopped partway is parked on its branch until a later
session picks it up by name. The same house rules govern how Claude works and
how it answers in every repository.

## What gets installed

Everything under `.claude/kit/` and the two skill directories. These files are
**kit-owned**: an install or update replaces them whole, and they are never
edited inside a project. A fix goes into this repository and reaches a project
by an update.

| Path | What it is |
|---|---|
| `.claude/kit/HOUSE.md` | The house rules: which file wins, the rules for every action, sessions and branches, the state files, the response format, and the Session Settings keys |
| `.claude/skills/session-open/SKILL.md` | Opens a session: reads the state, surveys the branches, puts the session on its task's branch, and runs the first-run setup in a repository new to the kit |
| `.claude/skills/session-close/SKILL.md` | Closes a session: places credentials, writes the state back, regenerates, pushes, and merges a finished task or parks an unfinished one |
| `.claude/kit/kit.sh` | Installs, updates, and reports the kit's status |
| `.claude/kit/todo_sweep.py` | Collects every `TODO:` in the repository into `TODO.md` |
| `.claude/kit/templates/` | The starting `CLAUDE.md`, `TASKS.md` and `HANDOFF.md` for the first run |
| `.claude/kit/MANIFEST` | Written by the install: the version, the source, the commit, and a checksum per file |

Everything else in a project is **project-owned** and an update never touches
it: `CLAUDE.md`, `TASKS.md`, `HANDOFF.md`, `TODO.md`, and anything the project
names as its authority file. A project's `CLAUDE.md` opens with
`@.claude/kit/HOUSE.md`, which imports the house rules, and holds a
`## Session Settings` section with every value that differs between
repositories. The skills name none of those values themselves.

The house rules live in `CLAUDE.md` by import rather than inside a skill
because a skill's text loads only when the skill is invoked, and a long session
can compact it away. `CLAUDE.md` loads at the start of every session and is
read again after compaction, and the response rules have to govern every turn.

## Install

In a Claude Code session on the repository, say:

> Install Claude-Kit from https://github.com/MrFieldTech/Claude-Kit, then follow
> its session-open skill.

The session runs:

```
git clone --depth 1 https://github.com/MrFieldTech/Claude-Kit "$(mktemp -d)/claude-kit"
bash <that clone>/.claude/kit/kit.sh install .
```

In a cloud session whose network refuses the clone, attach
`MrFieldTech/Claude-Kit` to the session with read access and run it again.

The install writes the kit-owned files into the working tree and commits
nothing. `session-open` then finds a repository new to the kit and runs its
first-run setup. It reads the repository to propose the Session Settings,
asks about whatever it cannot read, and creates the first task's branch. On
that branch it writes `CLAUDE.md`, `TASKS.md` and `HANDOFF.md` and commits
them with the kit. An existing `CLAUDE.md` is kept, and gains the import line
and the settings.

A skill installed partway through a session may not be listed until the next
session starts, which is why the install prompt says to follow the skill rather
than to run `/session-open`. From the next session on, `/session-open` works
as usual.

Two settings only the owner can change: GitHub's Automatically delete head
branches, which removes merged task branches, and a preview host's list of
branches to build, when there is one.

## Update

`/session-open` reports the kit on its `Kit:` line:

| Line | Meaning |
|---|---|
| `1.0.0, current` | The installed files match the source |
| `1.0.0, 1.1.0 available` | The source has a newer release |
| `..., edited locally: <files>` | A kit-owned file was changed in place. Move the change into the kit |
| `1.0.0, source unreachable` | The source could not be fetched. Nothing is wrong locally |
| `1.0.0, the source has no release on its default branch` | The source's `main` holds no `VERSION`, so no release has reached it |

An update happens only when the owner asks, on a task branch, as its own
commit:

```
bash .claude/kit/kit.sh update
```

It refuses to overwrite a kit-owned file edited in place unless it is given
`--discard-local-edits`, because that edit may be the only copy of a fix that
belongs here.

## Working on the kit

This repository runs on its own protocol, from the same files it ships. The
files under `.claude/kit/` and the two skills are the source, so there is no
`MANIFEST` here, and `kit.sh status` reports the source itself.

- **This repository is public.** A kit-owned file is installed into every
  repository, public or private, so it names no project, person, account,
  host, address or credential. `check.sh` refuses the project terms it knows
  about, and review catches the rest.
- **Every change to a kit-owned file is a release.** Bump `VERSION` and add a
  `CHANGELOG.md` entry in the same pull request.
- **`main` is what every install and update takes,** so it moves only when the
  owner asks, like the default branch of any repository using the kit.
- **Run `bash check.sh` before a pull request.** It checks the project terms,
  the em dash, the scripts and the skills. It also installs the kit into a
  scratch repository and exercises the install, status, update and the TODO
  sweep end to end. CI runs it on every pull request.
