# Changelog

Every change to a kit-owned file is a release, recorded here with the version
`VERSION` carries. A project's `/session-open` reports when a newer release
exists, and the project takes it by `kit.sh update` when its owner asks.

## 1.0.0

The first release, drawn from session skills that one repository had already
run for several weeks, with every value specific to that repository moved into
Session Settings.

- `HOUSE.md` holds the rules every repository shares: which file wins, the
  rules for every action, sessions and branches, the state files, the response
  format, and the definition of each Session Settings key.
- `session-open` and `session-close` read every repository-specific value from
  the `## Session Settings` section of `CLAUDE.md` and name none of their own.
- `session-open` has a first-run path for a repository new to the kit. It
  proposes the settings from what the repository shows, asks about the rest,
  and writes `CLAUDE.md`, `TASKS.md` and `HANDOFF.md` on the first task's
  branch.
- `session-open` reports the kit's version, and whether a newer one exists, on
  a `Kit:` line.
- A stray branch holding no commit the default branch lacks is reported without
  stopping the session, because nothing on it can be lost.
- An integration branch is a setting. With none, a finished task merges into
  the default branch and a blocked one parks.
- A credential goes where the Credentials setting sends it. With no rule, or in
  a repository not confirmed private, it is committed nowhere and handed to the
  owner in the report.
- `kit.sh` installs, updates and reports the kit, and will not overwrite a
  kit-owned file edited in place.
- `todo_sweep.py` collects every `TODO:` into `TODO.md` and refuses to
  overwrite a `TODO.md` it did not write.
