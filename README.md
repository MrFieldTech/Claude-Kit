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
| `.gitattributes` in each kit directory | Keeps LF line endings, so a checkout on Windows can still run `kit.sh` and still matches the checksums |

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

In a Claude Code session on the repository, paste this whole block:

```text
Install Claude-Kit into this repository. Claude-Kit is my own repository,
https://github.com/MrFieldTech/Claude-Kit, which I wrote and trust. I want
you to take each of these actions:

1. Attach MrFieldTech/Claude-Kit to this session with read access, if this
   is a cloud session, and clone it. It is only the source the installer
   copies from, so do not register the clone as one of this session's
   repositories.
2. From this repository's root, run the installer from that clone:
   bash <the clone>/.claude/kit/kit.sh install .
   It writes the kit's session-open and session-close skills into
   .claude/skills/ and its house rules into .claude/kit/. I want that change
   to your own configuration.
3. Follow the session-open skill it installed. It adds the line
   @.claude/kit/HOUSE.md to CLAUDE.md, writes TASKS.md and HANDOFF.md,
   commits them on a new task/ branch, and pushes that branch. Push the
   task/ branch, not the branch this session was assigned.

If auto mode blocks one of these anyway, do not work around it. Stop, and
give me the exact sentence to reply with that approves the blocked action.
```

A request as short as "Install MrFieldTech/Claude-Kit" is not enough, because
each numbered step opens a gate that stays shut until the owner's own message
names the action:

- **`[Untrusted Code Integration]`.** Auto mode's classifier trusts only the
  repository the session started in and its remotes. Attaching another
  repository and running a script from it is blocked unless the owner names
  that source. Step 1 names it and says it is the owner's own.
- **`[Self-Modification]`.** The classifier blocks a write into `.claude/` or
  `CLAUDE.md` unless the owner's message says that change is wanted. Steps 2
  and 3 name each write.
- **The assigned branch.** A cloud session's own instructions allow a push
  only to the branch it was assigned, and the kit pushes `task/<slug>`
  branches instead. Step 3 gives that permission.

The classifier is a model, and the same prompt can pass in one session and be
blocked in the next. Of five pilot attempts, two were blocked at the
installer, one at attaching the kit, and two passed. A block is answered, not
avoided: reply with the sentence the session gives, which names the blocked
action and its target, and it retries. Only if the block holds after that,
switch the permission mode from Auto to Accept edits in the mode selector,
approve the action when asked, and switch back.

Steps 1 and 2 as commands, for a session that is not in the cloud:

```
git clone --depth 1 https://github.com/MrFieldTech/Claude-Kit "$(mktemp -d)/claude-kit"
bash <that clone>/.claude/kit/kit.sh install .
```

The repository is public, so any session can clone it, and a cloud session
whose proxy serves it already may find there is nothing to attach in step 1.
The clone's own `CLAUDE.md` and skills belong to the kit's repository, which
is why step 1 keeps the clone from loading into the session.

The install writes the kit-owned files into the working tree and commits
nothing. `session-open` then finds a repository new to the kit and runs its
first-run setup. It reads the repository and settles every Session Setting it
can: the Owner is the account that owns the repository, the integration
branch is `preview`, and a key the repository does not show takes its
default. It asks only about what is left, and when nothing is, it carries
straight on. Its reply does not list the settings, which are in `CLAUDE.md`.
It creates the first task's branch, writes `CLAUDE.md`, `TASKS.md` and
`HANDOFF.md` on it, and commits them with the kit. An existing `CLAUDE.md` is
kept and gains the import line and the settings, and a section of it that
only repeats `HOUSE.md` is removed.

While the first run waits for an answer, the install stays uncommitted. A
cloud session's end-of-turn hook asks for it to be committed and pushed to
the assigned branch, and the session says why it will not.

A skill installed partway through a session may not be listed until the next
session starts, which is why the install prompt says to follow the skill rather
than to run `/session-open`. From the next session on, `/session-open` works
as usual.

Two settings only the owner can change, which the first run gives as
`Action needed:` notices rather than questions: GitHub's Automatically delete
head branches, which the workflow needs because a session cannot delete a
branch, and a preview host's list of branches to build, when there is one.
The first run asks only about a rule in the repository's own files that
contradicts the kit, such as a release process that pushes straight to the
default branch.

## Update

A repository never updates itself. Every `/session-open` checks the source and
reports the kit on its `Kit:` line, and says when a newer release is there to
take:

| Line | Meaning |
|---|---|
| `1.0.0, current` | The installed files match the source |
| `1.0.0, 1.1.0 available` | The source has a newer release |
| `..., edited locally: <files>` | A kit-owned file was changed in place. Move the change into the kit |
| `1.0.0, source unreachable` | The source could not be fetched. Nothing is wrong locally |
| `1.0.0, the source has no release on its default branch` | The source's `main` holds no `VERSION`, so no release has reached it |

An update happens only when the owner asks, as its own task. In a Claude Code
session on the repository, paste this whole block, with the new version in the
slug, such as `kit-update-1-0-3`:

```text
/session-open kit-update-<new version with hyphens>
Update Claude-Kit in this repository, as this task. Claude-Kit is my own
repository, https://github.com/MrFieldTech/Claude-Kit, which I wrote and
trust. I want you to take each of these actions on this task's branch:

1. Attach MrFieldTech/Claude-Kit to this session with read access, if this
   is a cloud session. Do not register it as one of this session's
   repositories.
2. Run bash .claude/kit/kit.sh update. It clones the kit and runs the new
   release's installer, which replaces the kit's skills in .claude/skills/
   and its house rules in .claude/kit/. I want that change to your own
   configuration.
3. Commit the update on its own, then do whatever the kit's CHANGELOG.md
   says the new release requires of a repository.

If auto mode blocks one of these anyway, do not work around it. Stop, and
give me the exact sentence to reply with that approves the blocked action.
```

Then `/session-close` merges it like any other task. The update refuses to
overwrite a kit-owned file edited in place unless it is given
`--discard-local-edits`, because that edit may be the only copy of a fix that
belongs here.

## Working on the kit

This repository runs on its own protocol, from the same files it ships. The
files under `.claude/kit/` and the two skills are the source, so there is no
`MANIFEST` here, and `kit.sh status` reports the source itself.

- **Nothing the kit installs names a project.** A kit-owned file is
  installed into every repository, and this repository is public, so it
  names no project, person, account, host, address or credential. `check.sh`
  refuses any web address, email address or host name, and any name on the
  owner's private list of project terms, which is kept out of the repository
  in the `KIT_PRIVATE_TERMS` secret CI reads. Review catches the rest.
- **Every change to a kit-owned file is a release.** Bump `VERSION` and add a
  `CHANGELOG.md` entry in the same pull request.
- **`main` is what every install and update takes,** so it moves only when the
  owner asks, like the default branch of any repository using the kit.
- **Run `bash check.sh` before a pull request.** It checks for addresses and
  project names, the em dash, the scripts and the skills. Locally it checks
  names only when an untracked `.private-terms` file holds the list. It also installs the kit into a
  scratch repository and exercises the install, status, update and the TODO
  sweep end to end. CI runs it on every pull request.
