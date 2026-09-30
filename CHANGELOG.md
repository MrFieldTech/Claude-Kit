# Changelog

Every change to a kit-owned file is a release, recorded here with the version
`VERSION` carries. A project's `/session-open` reports when a newer release
exists, and the project takes it by `kit.sh update` when its owner asks.

## 1.1.0

A temporary session, for questions without a branch.

- `/session-open temp` runs the fetch, the state reads, the kit check and the
  branch survey, then stays detached on the base and answers questions. It
  writes, commits and pushes nothing, a stray does not stop it, and in a
  repository new to the kit it does not run the first run.
- When a decision, a confirmed fact or a request for work comes up, it offers
  to keep it: to turn the session into a task, or to open a task for each
  topic to take up later. Each task's slug comes from the owner, or is
  proposed and asked. Its block records why it was made, what it is for, and
  the background, decisions and open questions from the session.
- From its first task on, it is an ordinary session that ends with
  `/session-close`. `session-close` says there is nothing to close for a
  temporary session that opened no task.
- `temp` is never a task slug, whatever the Reserved slugs setting says.

After updating: nothing is required. A repository with a task whose slug is
`temp` renames it, since `/session-open temp` no longer resumes it.

## 1.0.5

A credential is never committed in plaintext.

- `HOUSE.md` and `session-close` commit a credential only encrypted, by the
  method the Credentials setting names: the tool, and the public key or
  recipient it encrypts to. `session-close` no longer holds a value under
  Credentials In Transit "in full plaintext", which contradicted an authority
  file that requires encryption. A value bound for a committed file with no
  method named, or one the container cannot run, goes in the close report as
  the only copy, as a value does in a public repository.
- A value that spans more than one line, such as a private key or an
  encrypted block, is recorded whole in a fenced code block of its own, in
  `HANDOFF.md` and in the close report, never joined, wrapped, re-indented or
  put in a table.

After updating: a repository whose Credentials setting sends a value into a
committed file, `HANDOFF.md` included, adds the encryption method to that
setting in `CLAUDE.md`, or its sessions put every such value in the close
report instead. A value already committed in plaintext stays in the history
after it is replaced, so it is rotated, not only re-encrypted.

## 1.0.4

Hardening from the review before the repository went public.

- `kit.sh update` prints the source it is about to fetch and run, as
  `.claude/kit/MANIFEST` names it, so whoever reads the output can confirm
  it. The update prompt in `README.md` has the session check that source
  before updating, which works with every earlier `kit.sh`.
- `kit.sh` passes the source to `git clone` after `--`, so a source that
  begins with a dash cannot be read as an option.
- `session-close` creates the integration branch through its GitHub access
  when GitHub declines the push that would create it, which it does when the
  owner keeps their email address private and the default branch's head is a
  merge made under it.

After updating, nothing is required.

## 1.0.3

Fixes from the pilot's first full run, from install to a close that merged
into the default branch.

- `session-close` stays with a pull request until its checks finish, reading
  them about once a minute by a check-in a minute or two out, rather than one
  far out that leaves the merge idle after the checks pass.
- `session-close` merges the integration branch into the default branch
  without waiting for the checks to run again when they already passed on
  exactly that code: the integration branch's head is the task merge this
  session made after its checks passed, nothing else merged in between, and
  the default branch holds nothing the integration branch lacks. `HOUSE.md` says the checks must have
  passed on the code, not on the pull request itself.
- The session log row says a task reached the default branch when the owner
  asked for that merge in the session.
- The status blocks `session-open` and `session-close` report are one fenced
  code block with no backticks inside, which kept breaking apart.
- `session-open` says, when a newer release exists, that the update prompt is
  in the kit's README.

After updating, nothing is required.

## 1.0.2

Fixes from the third pilot attempt, which ran the first run to the end.

- The first run's reply no longer lists the Session Settings. They are in
  `CLAUDE.md`, and a value the owner is asked about carries its context in
  its question.
- Automatically delete head branches, and a preview host's branch list, are
  `Action needed:` notices at the top of the reply rather than questions,
  because the workflow needs them. `HOUSE.md` defines the notice.
- The first run asks about a rule in the repository's own files that
  contradicts `HOUSE.md`, such as a release process that pushes straight to
  the default branch, and leaves the file as it is until answered.
- `session-close` says on its `Branch:` line when a merged branch was not
  deleted, so the setting is turned on.

After updating, nothing is required.

## 1.0.1

Fixes from the first pilot, the first install outside the kit's own
repository.

- The first run settles more and asks less. The Owner is the account that
  owns the repository, read from its remote. The integration branch is
  `preview`, asked about only when a `preview` branch already exists. Checks
  before merge holds only commands the session's container can run, and
  leaves the rest to CI. A key the repository does not show takes its
  default. With nothing left to ask, the first run carries straight on.
- The first run removes a section of an existing `CLAUDE.md` that only
  repeats `HOUSE.md`, and asks only about one that says more. It adds the
  kit's paths to any file list a `README.md` or contributing guide keeps.
- While the first run waits for an answer, it leaves the install uncommitted
  and does not follow an instruction, such as an end-of-turn hook, to commit
  it to the branch the session was assigned.
- Each kit directory carries a `.gitattributes` keeping LF line endings. A
  checkout on Windows otherwise turns them into CRLF, which bash cannot run
  and which `kit.sh status` reports as a local edit.

After updating, nothing is required of a repository. A Windows checkout made
before the update keeps CRLF copies of the kit files the update did not
change, until they are checked out again: delete `.claude/kit/` and the two
skill directories and run `git checkout -- .claude`.

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
