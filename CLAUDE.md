@.claude/kit/HOUSE.md

# Claude-Kit

The session protocol and house rules shared by MrFieldTech's repositories, installed
into each one as a pinned copy. This repository is the source. The files under
`.claude/kit/` and the two skills in `.claude/skills/` are edited here and
nowhere else, and this repository's own sessions run on them directly.
`README.md` says what the kit is and how it is installed.

## Session Settings

Read by `session-open` and `session-close`, which name no value of their own.
What each key means is at the end of `.claude/kit/HOUSE.md`. Change a value
here, never in a kit-owned file.

- **Owner:** MrFieldTech
- **Authority file:** none
- **Default branch:** `main`. Every install and update takes it, so it moves
  only when MrFieldTech asks.
- **Integration branch:** `preview`
- **Other branches:** none
- **Task preview address:** none
- **Integration preview address:** none
- **Task slug limit:** 23
- **Reserved slugs:** none
- **Regenerate:** `python3 .claude/kit/todo_sweep.py --exclude check.sh`. The
  fixtures in `check.sh` are TODOs by design.
- **Generated files:** `TODO.md`
- **Checks before merge:** `bash check.sh`
- **Credentials:** none. Nothing here needs one, and this repository is
  public.
- **State file format:** kit templates

## Project rules

- **Nothing the kit installs names a project, and nothing here names the
  owner's other projects.** A kit-owned file is installed into every
  repository, and this repository is public, so it names no project, person,
  account, host, address or credential. When a name leaks in, remove it and
  have the owner add it to the `KIT_PRIVATE_TERMS` repository secret, which
  `check.sh` reads in CI, so it cannot return. The list itself never enters
  the repository.
- **Every change to a kit-owned file is a release.** Bump `VERSION`, add a
  `CHANGELOG.md` entry, and keep `README.md` true, all in the same pull
  request. A change that alters what a repository must do after updating
  says so in its entry.
- **The kit-owned files are the source here.** There is no `MANIFEST` in this
  repository, and the rule that kit-owned files are never edited applies to
  the repositories that install them, not to this one.
- **A skill stays generic by reading Session Settings.** A value that differs
  between repositories becomes a settings key, defined at the end of
  `HOUSE.md` and given a default in `.claude/kit/templates/CLAUDE.md`, never a
  literal in a skill.
