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

In a Claude Code session on the repository, say:

> Install Claude-Kit from https://github.com/MrFieldTech/Claude-Kit and follow
> its session-open skill. I want its skills and rules written into `.claude/`
> and imported by `CLAUDE.md`, and its `task/` branch pushed instead of this
> session's branch.

The second sentence is there for two gates a cloud session puts in front of
the install, each of which opens only when the owner names the action:

- **Auto mode's classifier** blocks a write into `.claude/` or `CLAUDE.md` as
  `[Self-Modification]` unless the owner's message says that change is
  wanted. "Install" alone does not say so.
- **The cloud session's own instructions** allow a push only to the branch it
  was assigned, and the kit pushes `task/<slug>` branches instead.

If the classifier blocks the install anyway, switch the permission mode from
Auto to Accept edits in the mode selector, approve the command when asked,
and switch back.

The session runs:

```
git clone --depth 1 https://github.com/MrFieldTech/Claude-Kit "$(mktemp -d)/claude-kit"
bash <that clone>/.claude/kit/kit.sh install .
```

The repository is private, so the clone needs access to it. A cloud session
attaches `MrFieldTech/Claude-Kit` itself when its tools allow, as every pilot
session did. Otherwise attach it with read access before the install. A
session without that access reports the kit's status as `source
unreachable`, and its installed copy keeps working. The clone is only the
source `kit.sh install` copies from. Its own `CLAUDE.md` and skills are this
repository's and are not meant to load into the session, so the clone is not
registered as one of the session's repositories. Auto mode blocked that in
one pilot, which did no harm.

The install writes the kit-owned files into the working tree and commits
nothing. `session-open` then finds a repository new to the kit and runs its
first-run setup. It reads the repository and settles every Session Setting it
can: the Owner is the account that owns the repository, the integration
branch is `preview`, and a key the repository does not show takes its
default. It asks only about what is left, and when nothing is, it carries
straight on. Its reply does not list the settings, which are in `CLAUDE.md`. It creates the first task's branch, writes `CLAUDE.md`,
`TASKS.md` and `HANDOFF.md` on it, and commits them with the kit. An existing
`CLAUDE.md` is kept and gains the import line and the settings, and a section
of it that only repeats `HOUSE.md` is removed.

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

- **Nothing the kit installs names a project.** A kit-owned file is
  installed into every repository, and this repository may be made public,
  so it names no project, person, account, host, address or credential.
  `check.sh` refuses the project terms it knows about, and review catches the
  rest.
- **Every change to a kit-owned file is a release.** Bump `VERSION` and add a
  `CHANGELOG.md` entry in the same pull request.
- **`main` is what every install and update takes,** so it moves only when the
  owner asks, like the default branch of any repository using the kit.
- **Run `bash check.sh` before a pull request.** It checks the project terms,
  the em dash, the scripts and the skills. It also installs the kit into a
  scratch repository and exercises the install, status, update and the TODO
  sweep end to end. CI runs it on every pull request.
