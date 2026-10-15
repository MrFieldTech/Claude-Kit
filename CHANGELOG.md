# Changelog

Every change to a kit-owned file is a release, recorded here with the version
`VERSION` carries. A project's `/session-open` reports when a newer release
exists, and the project takes it by `kit.sh update` when its owner asks.

## 1.6.0

Session references: each session leaves its facts where another repository
can import them.

- `session-close` writes a session reference at every close, one per task
  branch, at `.claude/references/<yymmddhhmmss>-<task-slug>.md`, the time
  in UTC, from `.claude/kit/templates/reference.md`: the task and its
  commit range, current state, decisions and who made them, verified facts
  with their sources, exact values, artifacts, gotchas, what is unverified,
  open questions, credentials by label, and one block per subject. It is
  never edited once committed. `HANDOFF.md` is written as before.
- The credentials a session handled go, each as a dated copy, into the
  reference's companion, `<yymmddhhmmss>-<task-slug>.secrets.md` beside it,
  by the Credentials setting's method. With `none`, or in a public
  repository, no companion is written, and the close says the repository
  has no method and offers to set one up. A value given in plaintext in
  the conversation draws a warning at close that the conversation still
  holds it.
- Credentials In Transit leaves the `HANDOFF.md` template and
  `session-close`: a value with no home yet lives in its session's
  companion. `secrets.py` still reads, checks and re-encrypts the heading
  where an older `HANDOFF.md` or an authority file keeps it.
- `secrets.py decrypt` and the Node decrypter skip `.claude/references/`,
  so a build never holds a second plaintext copy.
- `/session-open import` imports the references of the repositories
  `REFERENCES.md` names, on a task of its own, `import-<yymmddhhmmss>`.
  `import` is never a task slug, like `temp`. A repository turns imports
  on by the setup in `.claude/kit/references.md`, which writes
  `REFERENCES.md` from `.claude/kit/templates/REFERENCES.md`. Each import
  takes every reference a source's default branch added since the last
  one, one commit per reference, by the procedure the authority file or
  `CLAUDE.md` gives, or by the kit's default procedure, which says so until
  the owner dismisses the warning or writes their own. Credentials copy as
  they stand only when the source encrypts to the same keys; otherwise
  each arrives as a `TODO:`.
- In a public repository a reference holds nothing the repository's rules
  keep private, and the first run asks the owner to turn on secret
  scanning with push protection.
- `check.sh` tests a companion, the decrypt skip and the sweep skipping a
  reference.

After updating: references start at the next close, with nothing to set.
Delete the Credentials In Transit heading from `HANDOFF.md` when it holds
`None.`. When it holds values and the Credentials setting is `kit
standard`, move each into a companion with `secrets.py place`, or into its
home, and delete the heading after. Keep the heading when the authority
file requires it. A public repository turns on secret scanning with push
protection. Imports stay off until the owner asks for them.

## 1.5.0

The secrets standard is self-sufficient: whatever the kit encrypts, the kit
decrypts, makes keys for, and checks.

- `secrets.py decrypt --out <dir>` decrypts for a build. It copies every
  `<slug>.secrets.md` to the same path under a directory git ignores, with
  each value in plaintext, reading the key from `SECRETS_AGE_KEY`. It fails,
  writing nothing, on a missing key or a value that will not decrypt, naming
  the file and label and never the value. With `SECRETS_CHECK_BUILD=1` it
  needs no key and no `age` tool and writes a placeholder for every value.
- `.claude/kit/secrets-decrypt.mjs` does the same in Node, with the
  `age-encryption` package, offered only when `secrets.py decrypt` cannot
  run on the build host. No other way of decrypting is documented: a
  repository neither serves names its own method in Credentials, with the
  reason.
- `secrets.py keys` prints the steps for making the keys on the owner's
  computer, three by default, the owner's, the build's and a recovery key,
  or the holders named after it. A repository that names another set
  overrules the default.
- A new Session Settings key, Secrets checks, holds the repository's own
  checks on its handling of credentials. `session-close` runs them with
  `secrets.py check`.
- Credentials defaults to `none`. The first run sets `kit standard` only
  when the repository already holds credentials or the owner says it will.
  Switching runs the setup in `.claude/kit/credentials.md`: privacy, the
  keys, the repository's own checks, CI, and the build.
- When anyone asks how to encrypt a value, the session gives
  `secrets.py steps` from that repository, never a fixed set of keys.
- `check.sh` tests `decrypt`, the check build, its refusals and `keys`, and
  the Node decrypter when `node` is installed.

After updating: add `- **Secrets checks:** none` after the Credentials line
in Session Settings. A repository whose Credentials is `kit standard` runs
steps 3 to 5 of Setting it up in `.claude/kit/credentials.md`, writing its
Secrets checks, adding them and `secrets.py check` to its CI, and wiring
`secrets.py decrypt` into its build when one reads the values. A repository
with Credentials `kit standard` that holds no credentials and will hold none
may change it to `none`, and says so in the update's commit. One whose
Credentials names its own method keeps it.

## 1.4.0

Credentials have a standard: age encrypted `<slug>.secrets.md` files.

- `.claude/kit/credentials.md` describes it. Each credential sits in a
  `<slug>.secrets.md` file under a bold label, its value encrypted on its own
  with age to every public key in `secrets-recipients.txt` at the repository
  root, as an armored block fenced and tagged `age`. A value whose home is not
  settled waits under Credentials In Transit in `HANDOFF.md` in the same form.
  Private keys stay with the owner and never pass through a session.
- `.claude/kit/secrets.py` does every operation: `set`, `place` for a block
  the owner encrypted on their own computer, `lock`, `encrypt`, `show`,
  `rekey`, `check`, and `steps`, which prints the owner's encryption steps
  with the repository's keys written in. It needs `python3` and the `age`
  command line tool, and `check` needs `python3` alone.
- The Credentials setting takes `kit standard`, and the `CLAUDE.md` template
  defaults to it. A repository keeps its own place or rule, or `none`, by
  naming it instead. `HOUSE.md` points `kit standard` at the new document,
  and still commits no credential in a repository not confirmed private.
- The first run settles Credentials as `kit standard` unless the repository
  already keeps credentials another way, and asks the owner for keys when a
  private repository has none. `session-close` stores each value by the
  tool and commits nothing while `secrets.py check` fails.
- `check.sh` tests the tool end to end, and CI installs `age` to run it.

After updating: a repository whose Credentials setting is `none` changes it
to `kit standard`, unless it keeps credentials another way or is public, and
says so in the update's commit. A private repository taking the standard with
no `secrets-recipients.txt` puts `Action needed:` in the reply for the owner to
make keys, as `.claude/kit/credentials.md` says under Setting it up. A
repository whose Credentials setting names its own method keeps it.

## 1.3.0

Five practices, and a pull request body, run inside the existing workflow.

- `.claude/kit/practices/` holds five practices, each read when its case
  comes up rather than by a command of its own: grilling, diagnosing,
  writing for agents, questionnaire, and retrospective. `HOUSE.md` names
  each one and when it applies, and ranks them last under Which file wins.
- `session-open` settles a new task by grilling before it writes the task's
  block, and settles a decision a block leaves open before the step that
  needs it. A task blocked on answers someone other than the owner must give
  gets a questionnaire.
- `session-close` diagnoses a failing Regenerate command or check before it
  parks a task, and writes each pull request body as a summary, evidence and
  a merge danger call, the promotion into the default branch included. It
  looks back over a session that met friction, turns each proposal into an
  open question offering a task, and reports the count on a new `Retro:`
  line.
- The practices are plain files inside `.claude/kit/`, so `kit.sh` and the
  install are unchanged, and no name can collide with a skill a repository
  or a harness already has. They are adapted under the MIT License from a
  public collection of agent skills, whose notice is in `NOTICE.md`.
- `check.sh` fails when a practice is named by nothing, or a pointer names a
  practice that does not exist.

After updating: nothing is required.

## 1.2.0

A temporary session promotes the integration branch.

- Asked in any words, a temporary session merges the integration branch into
  the default branch by `session-close` step 9's checks, with no task and no
  close. It waits for the checks GitHub reports on the integration branch's
  head, and stops on an open pull request into the integration branch, which
  GitHub would retarget at the default branch.
- A conflict stops it, and it offers a task to resolve it on a branch from
  the integration branch. A conflict means a commit reached the default
  branch outside the protocol.
- A promotion from a temporary session records nothing in the repository. The
  pull request is the record. `session-close` step 9 still promotes when the
  owner asks during a close.

After updating: nothing is required.

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
