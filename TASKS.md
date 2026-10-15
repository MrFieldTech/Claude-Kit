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

### Write Session References And Import Them Into Other Repositories

**Slug:** `session-references`
**Status:** ACTIVE
**Opened:** 2026-10-14

**Why.** MrFieldTech, 2026-10-14. Facts a session learns in one repository
should reach another without a person carrying them, in any repository that
uses the kit, inside or outside the organization. The writer leaves a dated,
immutable record of each session's facts; the reader pulls those records
into a repository that asks for them and turns them into its own content.

**What was asked, as given.**

1. *Session references, the writer.* At every close, `session-close` writes
   one file to `.claude/references/<yymmddhhmmss>-<task-slug>.md`, time in
   UTC, in addition to `HANDOFF.md`, which stays unchanged. It is written
   once and never edited; a task spanning several sessions gets one per
   session. It records facts, not finished documentation, in a generic shape
   roughly molded on a chat handoff: the task and its commit range, current
   state, decisions with who made them, verified facts each with its source,
   exact values (paths, addresses, commands, versions), artifacts, gotchas,
   flagged as unverified, open questions, and one block of facts per subject
   (each system, account, service, process or project the session worked
   on). With nothing worth recording, its facts say None. It names no
   importer and copies no other repository's rules. `.claude/references/`
   sits outside `.claude/kit/` and the TODO sweep skips it. A reference names
   each credential by id, never a value. With Credentials `none`, the session
   says the repository has no credential method, offers to set one up, and
   commits no value. With a method, the values go encrypted, one labelled
   block each, in a companion `<yymmddhhmmss>-<task-slug>.secrets.md`. A
   value given in plaintext in the session draws a warning at close that the
   conversation holds it and should be erased.
2. *The import system, the reader.* A setup step a repository runs to turn
   it on, which builds `REFERENCES.md` at its root: each source repository in
   scope, those excluded with the reason, and the last reference imported
   from each. `/session-open import` (`import` becomes a reserved word, like
   `temp`) reads `REFERENCES.md`, attaches each source read-only, and lists
   the references newer than the last import. With none it stops and writes
   nothing. Otherwise it opens task `import-<yymmddhhmmss>` on its task
   branch and imports each reference by the procedure the repository's
   authority file or `CLAUDE.md` gives for turning facts into its own
   content, asking about anything it cannot settle, then records the last
   import per source. Under `kit standard`, it compares the source's
   `secrets-recipients.txt` with its own. On a match it copies each block as
   it stands. On a difference it copies none, writes a TODO asking for the
   value encrypted to its own keys, and the setup warns of this up front.
3. Both are a release: `VERSION`, `CHANGELOG.md` and `README.md`, with what
   an updating repository must do.

**Facts looked up, 2026-10-14.**

- `todo_sweep.py` already skips every path under `.claude/`, so
  `.claude/references/` needs no change to the sweep.
- `kit.sh` owns only `.claude/kit/` and the two skill directories, so an
  install or update never touches `.claude/references/` or `REFERENCES.md`.
- `secrets.py check` reads every tracked `*.secrets.md`, wherever it sits,
  and requires frontmatter of `slug` and `updated` alone, the slug matching
  the filename. A companion passes as `slug: <yymmddhhmmss>-<task-slug>`.
  `rekey` re-encrypts it in place, and `decrypt` (and the Node decrypter)
  would copy it into a build's output as it stands.
- `secrets.py place` refuses a block encrypted to a different number of keys
  than `secrets-recipients.txt` lists, and cannot tell the right keys from
  the wrong ones of the same count.
- `check.sh` checks addresses and the private terms only in kit-owned
  directories, so a reference committed in this public repository is not
  checked for the owner's other projects.
- The slug `import-<yymmddhhmmss>` is 19 characters, inside the default
  Task slug limit of 23.
- Version 1.5.0 is current; this is 1.6.0, new features with no breaking
  change.

**Decisions made.** MrFieldTech, 2026-10-14, round 1 of grilling.

- The import reads each source's default branch, so only promoted work is
  imported.
- `REFERENCES.md` records, per source, the last reference imported and the
  source commit it was read at. Newer means every reference added to the
  source since that commit, so a late-merging reference is still caught.
- Every repository writes references at every close, with no setting:
  little cost in tokens or storage, and they may help later in ways not
  yet seen.
- A companion holds every value the session produced, was given or
  changed, as a dated copy beside its home.
- The first import from a new source imports every reference it holds.
- The import task's own reference records each source and reference it
  imported, by name, and only facts its session verified, never the
  imported facts, so two repositories importing each other cannot loop.
- When the importing repository is not `kit standard`, no value is copied.
  The import names each credential by id with a TODO and asks the owner
  what to do with it, recommending the kit's credentials setup.
- `secrets.py decrypt` and the Node decrypter skip `.claude/references/`,
  so a build never holds a second plaintext copy.
- `check.sh` extends its private-terms check to `.claude/references/` in
  this repository.

MrFieldTech, 2026-10-14 and 2026-10-15, rounds 2 and 3 of grilling.

- Credentials In Transit leaves the `HANDOFF.md` template and
  `session-close`. A value with no home yet lives only in its session's
  companion, and the task opened to place it names that companion.
  `secrets.py` still reads the heading where an older `HANDOFF.md` or an
  authority file keeps it, and an updating repository moves any value held
  there into a companion.
- When the repository gives no import procedure, the import runs the kit's
  default and says so, because the repository's own way probably differs.
  The owner either dismisses the warning for good, recorded in
  `REFERENCES.md` with who and when, or answers a few questions that write
  the repository's own procedure.
- The default is modelled, with the owner's approval of 2026-10-15 to
  publish it unnamed, on how one of the owner's private repositories
  already promotes chat handoffs. It must work for any repository but
  first of all as that repository works today, and must not turn every
  import into a long round of questions: it asks only what it cannot
  record. Each subject becomes `imported/<subject-slug>.md`, or reconciles
  into the file already there: the newer reference wins on facts, every
  unique fact carries over, and a conflict is written onto the file with a
  `TODO:` rather than settled by picking a side. A fact flagged as
  unverified becomes a `TODO:` quoting the reference. New files are listed
  in the report, not asked about. Questions and unverified facts above any
  one subject go to `HANDOFF.md`. Nothing is deleted.
- This repository: the owner adds `KIT_PRIVATE_TERMS` to the cloud
  environment's variables, a project rule in `CLAUDE.md` has the close
  replace each match in a reference with `[redacted]` before committing
  it, `check.sh` fails on any match left, and the owner turns on secret
  scanning with push protection.
- Every repository: a `HOUSE.md` rule that a reference in a public
  repository, or one whose visibility cannot be confirmed, holds no detail
  the repository's own rules keep private, and the first run gives an
  `Action needed:` to turn on secret scanning with push protection in a
  public repository.

Grilling is done: the frontier is empty.

**The build.**

- `.claude/kit/references.md`, new: the reference and its companion, the
  setup that turns imports on, `REFERENCES.md`, the import, and the kit's
  default import procedure.
- `.claude/kit/templates/reference.md` and `templates/REFERENCES.md`, new.
- `session-close`: write the reference and its companion, stage them in the
  handoff commit, the plaintext warning, a `Reference:` report line, and no
  Credentials In Transit.
- `session-open`: `/session-open import`, `import` never a task slug, and
  the first run's secret scanning notice.
- `HOUSE.md`, `credentials.md`, `templates/HANDOFF.md`: references,
  companions, no Credentials In Transit, the public repository rule.
- `secrets.py` and `secrets-decrypt.mjs`: decrypt skips `.claude/references/`.
- `check.sh`: private terms over `.claude/references/`, the decrypt skip,
  the new templates. `CLAUDE.md`: the redaction rule.
- Release 1.6.0: `VERSION`, `CHANGELOG.md`, `README.md`.

**Round 2, as asked** (answered above):

1. Credentials In Transit, now that companions hold every value: a) remove
   the heading from the `HANDOFF.md` template and `session-close`; a value
   with no home yet lives only in its session's companion, and the task
   opened to place it names that companion. `secrets.py` still reads the
   heading where an older `HANDOFF.md` has one, and an updating repository
   moves any value held there into a companion (recommended); b) keep it
   as it is.
2. An import must turn a reference's facts into the repository's own
   content, such as a page per subject or lines in a notes file, by a
   procedure written in the authority file or `CLAUDE.md`. When the
   repository has written none: a) the setup asks the owner how facts
   become content there and writes the answer into `CLAUDE.md` under a
   heading of its own, and the import refuses to run until it exists
   (recommended); b) the kit gives a default, such as adding each
   reference's facts to one `IMPORTED.md`.
3. Hashing out private text in this repository's references: a cloud
   session has no list of terms, which lives only in the CI secret, so it
   cannot check a reference before the push that publishes it on this
   public repository. a) the owner adds `KIT_PRIVATE_TERMS` to the cloud
   environment's variables; a project rule in `CLAUDE.md` has the close
   replace each match with `[redacted]` before committing the reference,
   and `check.sh` fails on any match left (recommended); b) the close
   writes references here naming no other project, and a match CI finds
   after the push is redacted by a new commit, the history keeping it;
   c) both.

**Round 1, as asked** (answered above):

1. Which branch of a source the import reads: a) its default branch, so
   only work the owner promoted is imported (recommended); b) its
   integration branch; c) both.
2. How "newer than the last import" is found: a) `REFERENCES.md` records,
   per source, the last reference imported and the source commit it was
   read at, and newer means every reference added since that commit, so a
   parked task's reference with an older timestamp that merges late is
   still caught (recommended); b) by filename timestamp alone.
3. Whether every repository writes references: a) always, no setting, as
   asked (recommended); b) a new Session Settings key that can turn it off.
4. Which credentials go in a companion: a) every value the session
   produced, was given or changed, a dated copy beside its home
   (recommended); b) only values with no other home in the repository.
5. When neither the authority file nor `CLAUDE.md` gives an import
   procedure: a) the setup asks the owner for it and writes it into
   `CLAUDE.md` under a heading of its own, and an import refuses to run
   without one (recommended); b) the kit supplies a default procedure.
6. The first import from a new source: a) imports every reference it holds
   (recommended); b) the setup marks the newest as imported, and only later
   ones import.
7. The import task's own reference: a) records what it imported, each
   source and reference by name, and only facts the session itself
   verified, never re-copying imported facts, so two repositories importing
   each other do not loop (recommended); b) records the imported facts too.
8. Credentials when the importing repository is not `kit standard`: a) copy
   no value; name each id with a TODO asking the owner to place it by the
   repository's own method, or to set one up (recommended); b) refuse to
   import a reference whose companion holds values.
9. `secrets.py decrypt` and the Node decrypter: a) skip
   `.claude/references/`, so a build never holds a second plaintext copy
   (recommended); b) decrypt companions like any secrets file.
10. This public repository's own references may name the owner's other
    projects: a) extend `check.sh`'s private-terms check to
    `.claude/references/` here (recommended); b) also its address check;
    c) neither.

**Stopping point.** Built, every item under The build, and `bash
check.sh` passes on it. Next: `/session-close` merges it into `preview`.
Before the first real import, the private record repository whose
procedure the default follows needs its authority file to name an import
procedure, its own or the kit default, and it copies no credential until
it switches to `kit standard`.

## Closed Tasks

### Make The Kit's Secrets Standard Self-Sufficient

**Slug:** `secrets-self-sufficient`
**Status:** DONE
**Opened:** 2026-10-12
**Closed:** 2026-10-12

**Why.** MrFieldTech, 2026-10-12, while switching the private repository
whose process became the 1.4.0 standard over to `kit standard`. That
repository decrypts credentials in its own site build, and `secrets.py` has
no command for it, so it could not switch without keeping its own script.
The owner wants the kit to be self-sufficient: whatever the kit encrypts, the
kit can decrypt, so a repository takes the whole standard and keeps only what
is particular to it. One task, one release, covers all three parts below.

**Background.** What that repository's build does today, which the owner
wants the kit's default to resemble so its switch changes little:

- The build's first step decrypts every value in every `<slug>.secrets.md`
  into a gitignored directory, reading the private key from the environment
  variable `SECRETS_AGE_KEY`. Later steps read the decrypted copy in place of
  the encrypted one.
- It fails the build when the variable is missing or a value will not
  decrypt, naming the file and label and never the value, because a build
  without its credentials looks complete and is not.
- A check build, asked for with `SECRETS_CHECK_BUILD=1`, holds no key and
  writes a fixed placeholder for every value, so continuous integration can
  build without a key.
- Decryption drops `\r\n` line endings and one trailing line break, so a
  value typed into Windows Command Prompt reads as typed.
- It decrypts in Node with the `age-encryption` package, pinned in the
  lockfile, because its build host has Node and may not have the `age`
  command line tool. `secrets.py` calls the `age` tool.
- A separate output check fails the build when a decrypted value reaches the
  search index or an encrypted block reaches a page. That one is particular
  to a repository that publishes a site.

What 1.4.0 already provides toward the other two parts:

- `secrets.py steps` prints the Windows and macOS or Linux encryption steps
  with the repository's own keys from `secrets-recipients.txt` written in.
- `credentials.md`, Setting it up, and the first run have the session ask the
  owner for keys when a private repository taking `kit standard` has none.

**Decisions.**

- MrFieldTech, 2026-10-12: the kit carries decryption. The default resembles
  the build described above, with options to decrypt another way. The owner
  is not sure what the other ways are, so the session lists them.
- MrFieldTech, 2026-10-12: in every repository, when a person asks how to
  encrypt a value to hand to a session, the session gives the steps with
  that repository's keys, never a fixed set from the kit.
- MrFieldTech, 2026-10-12: when a repository has no keys yet, the kit
  provides the process to create them and give the public halves to the
  repository, and only for a repository that is going to keep credentials.
  Some repositories never need the feature.
- MrFieldTech, 2026-10-12: every secrets check comes from the kit. Because
  repositories differ, installing the secrets standard has the session review
  the repository and write a list of checks particular to it, which are then
  run alongside the kit's.

- MrFieldTech, 2026-10-12, first round: the kit ships both a
  `secrets.py decrypt` command, the default, matching the build described
  above, and a Node decrypter. A session offers the Node decrypter only when
  `secrets.py decrypt` cannot run in the repository's build environment.
- MrFieldTech, 2026-10-12, first round: the kit documents no other way of
  decrypting. A repository that neither decrypter serves implements its own
  encryption and decryption, and the kit's secrets standard is marked unused
  there for that reason. Finding it another way is not the kit's job.
- MrFieldTech, 2026-10-12, first round: the first run sets Credentials to
  `none` unless the repository already holds credentials or the owner says
  it will. Switching to `kit standard` later runs setup: first the keys, then
  the repository's own list of checks.
- MrFieldTech, 2026-10-12, first round: a `secrets.py` command prints the
  steps for making the keys on the owner's own computer, three by default,
  the owner's, the build's and a recovery key, and the session writes
  `secrets-recipients.txt` from the public halves the owner returns. A
  repository that says otherwise, in its authority file or `CLAUDE.md`,
  overrules the default set.
- MrFieldTech, 2026-10-12, first round: a repository's own secrets checks
  live in a new Session Settings key in `CLAUDE.md`, one command per check,
  run by `session-close` and CI beside `secrets.py check`.

- MrFieldTech, 2026-10-12, second round: a repository marks the kit's
  secrets standard unused by naming its own method in the Credentials
  setting in place of `kit standard`, with the reason the kit's decrypters
  do not serve. Every secrets command, check and setup step applies only
  under `kit standard`.
- MrFieldTech, 2026-10-12, second round: `secrets.py decrypt` writes a copy
  of each `<slug>.secrets.md` at the same path under a gitignored output
  directory, `--out <dir>`, with every value in plaintext, and the build
  reads the copy in place of the encrypted file.
- MrFieldTech, 2026-10-12, second round: setup adds `secrets.py check` and
  the repository's own secrets checks to its CI configuration on the task
  branch when it has one, and otherwise puts `Action needed:` at the top of
  part 1.

**Plan.** One release, 1.5.0.

1. `secrets.py decrypt --out <dir>`: every `<slug>.secrets.md`, never
   `HANDOFF.md`, copied to the same relative path under `<dir>` with each
   value written as `show` writes it. The key comes from `SECRETS_AGE_KEY`
   or `--identity`. It refuses a missing key, an output directory git does
   not ignore, and a value that will not decrypt, naming the file and label
   and never the value. With `SECRETS_CHECK_BUILD=1` it needs no key and no
   `age` tool and writes a fixed placeholder for every value. Windows line
   endings and one trailing line break are dropped, as `show` already does.
2. `.claude/kit/secrets-decrypt.mjs`: the same command for Node, with the
   same output, refusals and check build, using the `age-encryption`
   package the repository pins. `credentials.md` says a session offers it
   only when `secrets.py decrypt` cannot run in the build environment.
3. `secrets.py keys [<holder>...]`: prints the steps for making the keys on
   the owner's own computer, Windows and macOS or Linux, one per holder,
   `owner`, `build` and `recovery` by default, and what to send back. The
   session writes `secrets-recipients.txt` from the public lines returned.
   A repository that names another set in its authority file or `CLAUDE.md`
   overrules the default.
4. A new Session Settings key, **Secrets checks**, after Credentials: one
   command per check particular to the repository, or `none`. Defined at the
   end of `HOUSE.md`, given `none` in `templates/CLAUDE.md` and in this
   repository's `CLAUDE.md`. `session-close` runs `secrets.py check` and
   each of them when Credentials is `kit standard`.
5. Credentials: the template default becomes `none`. The first run sets
   `none` unless the repository already holds credentials or the owner says
   it will. `HOUSE.md` says a repository whose needs the kit's decrypters do
   not serve names its own method there, with the reason, and that every
   secrets command, check and setup step applies only under `kit standard`.
6. `credentials.md`, Setting it up, becomes the setup run when Credentials
   switches to `kit standard`: the keys by `secrets.py keys`; then a review
   of the repository that writes Secrets checks; then `secrets.py check`
   and those checks added to its CI configuration, or `Action needed:`;
   then, when a build reads the values, its first step `secrets.py decrypt`
   with the build's key as `SECRETS_AGE_KEY` on the host, a check build
   with `SECRETS_CHECK_BUILD=1`, and the output directory gitignored. When a
   person asks how to encrypt a value, the session gives `secrets.py steps`
   with that repository's keys.
7. `check.sh` fixtures for decrypt, the check build, the refusals, and
   `keys`, and for the Node decrypter when `node` and the package are
   present.
8. `VERSION` 1.5.0, a `CHANGELOG.md` entry saying what an updated
   repository must do (add the Secrets checks key; one keeping credentials
   runs setup's review), and `README.md`, its update slug `kit-update-1-5-0`.

**Outcome:** Every plan step is done and `bash check.sh` passes, with the
Node decrypter tested in full against a local `age-encryption` 0.3.1.
Release 1.5.0.

### Make Age-Encrypted Secrets Files The Kit's Standard For Credentials

**Slug:** `age-secrets`
**Status:** DONE
**Opened:** 2026-10-11
**Closed:** 2026-10-12

**Why.** MrFieldTech, 2026-10-11, in a temporary session, asked whether the
kit uses age-encrypted `<slug>.secrets.md` files for credentials. It does not:
`HOUSE.md` and `session-close` leave the method to each repository's
Credentials setting, and the kit only knows the filename, in that
`todo_sweep.py` skips `*.secrets.md`. The owner decided the process becomes
the standard way every repository installing the kit handles secrets,
tokens and credentials, and that a repository may replace it with its own.

**Background.** The owner pointed at one of their private repositories, which
already runs the process, as the model. It is not named here, because this
repository is public. What it does:

- Each credential sits beside what it belongs to in `<slug>.secrets.md`: two
  frontmatter fields, `slug` and `updated`, then one bold label per value,
  the value as an ASCII armored age block fenced and tagged `age`, and an
  optional plaintext note. The label and note never hold a value.
- Every value is encrypted on its own to every public key listed in
  `secrets-recipients.txt` at the repository root, one key per line under a
  comment naming who holds the private half. Encrypting needs only the public
  keys. Any one private key reads every value. A private key is never
  committed, never written into a state file, and never passed through a
  session.
- One script does every operation: `set` (value on standard input, never on
  the command line), `place` (store a block the owner encrypted on their own
  computer, refusing one that is not armored age, is passphrase-locked, or
  has a different number of recipients), `lock` (encrypt plaintext values in
  place), `encrypt` (print a block for Credentials In Transit in
  `HANDOFF.md`), `show` (decrypt with a key), and `rekey` (re-encrypt every
  value, `HANDOFF.md` included, after a recipient changes).
- An audit fails on a value outside an encrypted block, in a table, or in a
  fence not tagged `age`, and on an `age` block that is not armored age.
- A value with no home yet goes under Credentials In Transit in `HANDOFF.md`
  as a label and an encrypted block.
- The owner can encrypt a value on their own computer with the `age` command
  line tool and hand the session only the armored file, so the plaintext never
  enters the conversation.

**Decisions.**

- MrFieldTech, 2026-10-11: the age process is the kit's default for every
  repository, and a repository overrides it through its Credentials setting.
- MrFieldTech, 2026-10-11: the earlier rule stands that nothing is committed
  in a repository not confirmed private, encrypted or not.

**Plan.** A release of the kit: a stdlib Python tool in `.claude/kit/` that
calls the `age` command line tool, the format and the steps in a kit
document, the default in `HOUSE.md`, `session-close` and the `CLAUDE.md`
template, tests in `check.sh` with CI installing `age`, and `VERSION`,
`CHANGELOG.md` and `README.md` to match.

**Done.** Release 1.4.0: `.claude/kit/credentials.md`, `.claude/kit/secrets.py`,
`HOUSE.md`, both skills, the `CLAUDE.md` template (`Credentials: kit
standard`), `check.sh` section 6, CI installing `age`, `VERSION`,
`CHANGELOG.md` and `README.md`. This repository's own Credentials setting
stays `none`, because it is public. MrFieldTech, 2026-10-12, asked for it to
be merged and promoted to `main`.

### Fold Six Workflow Practices Into The Session Protocol

**Slug:** `workflow-practices`
**Status:** DONE
**Opened:** 2026-10-11
**Closed:** 2026-10-11

**Why.** MrFieldTech, 2026-10-11, in a session outside any repository using
the kit, had a public collection of agent skills reviewed against the kit,
a documentation repository and a static site, and accepted six of them as
worth adopting: an interview that settles a plan before it is built, a
disciplined loop for diagnosing failures, a pull request body with evidence
and a merge danger call, a reference for writing documents agents read, a
retrospective on the session's environment, and a questionnaire for
knowledge someone else holds. The rest were declined because they bring a
second work queue, a second handoff, or a second branch model.

**What MrFieldTech asked for, 2026-10-11.**
1. Integrate the six into the kit, so every repository using it has them.
2. Run the interview in the new task flow, before a task's block is
   written.
3. Have the diagnosis loop run on its own from the checks the protocol
   already runs, when one fails.
4. Copy the useful parts of the pull request body into `session-close`.
5. The aim: no new command to remember. Each practice runs at a point the
   existing workflow already reaches, or when the situation it covers
   comes up.

**Decided by MrFieldTech, 2026-10-11.** The practices live in the kit, as
part of its pinned copy, rather than as a self-updating plugin or as files
copied into each repository by hand.

**Plan.** A kit release, 1.3.0:
1. Plain reference files under `.claude/kit/practices/`, one per practice
   except the pull request body, which goes into `session-close` itself.
   They sit inside an existing kit directory, so `kit.sh` and the install
   are unchanged, and they are not skills, so no name can collide with a
   skill a repository or a harness already has.
2. `HOUSE.md` gains a short section of pointers naming when each practice
   applies, because it is the one file every turn has loaded.
3. `session-open` runs the interview before writing a new task's block;
   `session-close` diagnoses a failing Regenerate command or check before
   parking, writes the pull request body, and looks back over the session
   before writing `HANDOFF.md`.
4. `check.sh` fails when a practice file is missing, or is pointed at by
   nothing.
5. `VERSION`, `CHANGELOG.md` and `README.md`, including its update slug.
6. The source collection's license notice travels with the practices.

**Done, 2026-10-11, on the branch.** Release 1.3.0, as planned. The
practices are `grilling.md`, `diagnosing.md`, `writing-for-agents.md`,
`questionnaire.md` and `retro.md`. `session-open` grills in step 4 case c,
which cases d and the temporary session's tasks reach too, and in step 6 for
a decision a block leaves open. A blocked task gets a questionnaire while
working. `session-close` runs the retrospective at step 4, diagnoses at step
5 and at both failure points of step 8, writes the pull request body in
step 8 and the promotion's in step 9, and reports a `Retro:` line.
`bash check.sh` passes, each new guard was made to fail on purpose, and a
scratch repository on 1.2.0 updated to 1.3.0 and reported current.

A retrospective's proposals go under Open Questions in `HANDOFF.md`,
because its headings are fixed and a proposal is a decision for the owner,
not a task the session opens on its own.

**Decided by MrFieldTech, 2026-10-11.**
- The license notice, which names the source collection's author, stays
  only in `NOTICE.md` at the root and is not installed. Each practice
  credits the collection without naming it, by the project rule that a
  kit-owned file names no person.
- 1.3.0 goes to `main` at this close.
- MrFieldTech updates the repositories using the kit by the README's update
  prompt, in a session on each, rather than this session doing it.

**Closed, 2026-10-11.** Closed by 1.3.0's own `session-close`, whose pull
request bodies and retrospective ran for the first time here. Merged into
`preview` and then `main` at MrFieldTech's request.

### Promote Preview Into Main Without A Task

**Slug:** `preview-promotion`
**Status:** DONE
**Opened:** 2026-10-01
**Closed:** 2026-10-01

**Why.** MrFieldTech, 2026-10-01, in a temporary session, asked how preview
is merged into main: whether to ask a random session after `/session-close`
or to start a whole session just for the merge. Today the merge is step 9 of
`session-close`, and it runs only when the owner asked for it in that same
session. So it rides on a session that closes a task. Asking after a close has
finished does nothing, because step 9 is part of the close. A merge on its own
has no clean path: a temporary session writes nothing, `session-close` stops
at once for a temporary session that opened no task, and an ordinary session
must open a task, which adds a task block to `TASKS.md` just to carry the
merge.

**What the session found about conflicts.** Main moves only by pull requests
from preview, and when GitHub deletes preview after a promotion,
`session-close` step 8 recreates it at main's head. So main is normally an
ancestor of preview, and the promotion cannot conflict. On 2026-10-01 main
(`b114510`) was an ancestor of preview (`9c6062a`), which was 4 commits ahead
with `readme-version-update`. A merge commit on main that preview lacks, when
preview was not deleted, carries no change of its own and does not conflict
either. A real conflict needs a commit that reached main outside the protocol:
a direct push, an edit on GitHub's website, or a pull request from another
branch. Resolving one cannot happen on preview or main, since neither takes a
direct commit. It needs a task branch cut from preview that merges main in,
with the owner's answers on the conflicting files, and a pull request back
into preview. That path is already the ordinary task flow.

**What a promotion records.** Every past promotion added a line to the
`HANDOFF.md` session log, such as "merged into preview and then main at
MrFieldTech's request". A temporary session commits nothing, and it cannot
commit to preview or main either, so a promotion run from one records nothing
in the repository. The pull request into main and its merge commit are the
record on GitHub.

**Direction from MrFieldTech, 2026-10-01.** If a promotion never needs a
conflict resolution recorded, it can run as part of a temporary session,
something like `/session-open temp promote preview`, rather than on its own
branch.

**To do.** A kit release (bump `VERSION`, add a `CHANGELOG.md` entry, set the
README's update slug, keep `README.md` true):
1. Settle the open questions below with MrFieldTech.
2. Give `session-open`'s temporary session a promotion form that runs
   `session-close` step 9's three checks and, when all pass, opens and merges
   the pull request from preview into main. When a check fails, it names the
   check and stops. On a conflict it reports the files and proposes a task to
   resolve them, by the conflict rule in `HOUSE.md`.
3. Make `HOUSE.md`'s rule that a temporary session writes and pushes nothing
   name the exception: it opens and merges that one pull request. Make
   `session-close` step 9 point to the new form for a merge with no task.
4. With `Integration branch: none`, the form has nothing to do and says so.

**Decisions, MrFieldTech, 2026-10-01.**
- No keyword. `temp` is the session, and asking it to promote is an ordinary
  request in any words, which the session works out from the conversation.
- A promotion from a temporary session leaves no line in the `HANDOFF.md`
  session log. The pull request into main is the record.
- `session-close` step 9 stays, so a close still promotes when asked.

Done in release 1.2.0: `session-open`'s Temporary Session section promotes by
`session-close` step 9, waits for the checks on the integration branch's head,
stops on an open pull request into it, and offers a task on a conflict.
`HOUSE.md`, `session-close` step 9, `README.md`, `VERSION` and `CHANGELOG.md`
match.

Merged into preview and then main at MrFieldTech's request on 2026-10-01.

### Keep The README Update Prompt On The Current Version

**Slug:** `readme-version-update`
**Status:** DONE
**Opened:** 2026-09-30
**Closed:** 2026-09-30

MrFieldTech, 2026-09-30: the README's copy and paste block for updating
Claude-Kit in a repository opens with
`/session-open kit-update-<new version with hyphens>`. Make that line name the
version the kit is currently on, and keep it current: every version change
already changes the repository, so it updates the README to the version a
repository can update to as well.

Done: the update block's slug reads `kit-update-1-1-0`, the text
above it says the slug names the current release, the README's and
`CLAUDE.md`'s release rules add setting that slug, and `check.sh` section 4
fails when the slug does not match `VERSION`. README and `check.sh` are not
kit-owned, so this is not a release.

### Add A Temporary Session

**Slug:** `add-session-temp`
**Status:** DONE
**Opened:** 2026-09-30
**Closed:** 2026-09-30

MrFieldTech, 2026-09-30: there should be a temporary session option that
opens a session for questions about the repository and its details without
creating a task branch or anything that follows from one. If, during a
temporary session, MrFieldTech asks for branches to use later, creating them
is fine, but the temporary session itself creates none of that. MrFieldTech
asked for opinions first.

**Decided by MrFieldTech, 2026-09-30.**

1. The command is `/session-open temp`. If the owner later wants to build or
   keep something, the session asks for a slug or takes the one given,
   checks out that task's branch, and either records what is to be kept or
   starts building.
2. When a decision or a request for work comes up, the session offers to
   turn itself into a task or to open a new one, whichever fits, and may
   offer several when the session covered several topics.
3. A branch for later is a parked task, and its block records why it was
   made, what it is for, and as much background as it needs.

**Done, 2026-09-30, on the branch.** Release 1.1.0: a Temporary Session
section in `session-open`, a paragraph in `HOUSE.md`, `temp` reserved in
every repository, `session-close` stops with nothing to close for a temporary
session that opened no task, and `README.md` and `CHANGELOG.md` describe it.
`bash check.sh` passes. Not yet tried in a real temporary session.

**Closed, 2026-09-30.** MrFieldTech asked for 1.1.0 to reach `main`.

### Encrypt Credentials Committed In Transit

**Slug:** `multi-line-secrets`
**Status:** DONE
**Opened:** 2026-09-28
**Closed:** 2026-09-28

MrFieldTech, 2026-09-28: step 4 of `session-close` says a value held under
Credentials In Transit in `HANDOFF.md` is kept "in full plaintext". A
project's authority file says such values are encrypted, and it wins in that
project, but the kit should not say the opposite. Secrets should be
encrypted in transit. Make the kit hold a committed credential only
encrypted, by a method the Credentials setting names, keep the kit generic,
and record a value that spans more than one line, such as an encrypted
block or a key file, so that it survives whole.

**Done, 2026-09-28, on the branch.** Release 1.0.5: `HOUSE.md` never commits
a credential in plaintext, and the Credentials key names the encryption
method, the tool and the public key or recipient, for any place inside the
repository. `session-close` step 2 encrypts a value bound for a committed
file by that method and checks the output does not contain it, and sends it
to the close report as the only copy when no method is named or the
container cannot run it. Step 4 holds a value under Credentials In Transit
encrypted, with its method. A value that spans lines is kept whole in a
fenced block of its own, in `HANDOFF.md` and in the report. `bash check.sh`
passes.

**Closed, 2026-09-28.** MrFieldTech kept the rule that nothing is committed,
encrypted or not, unless the repository is confirmed private, and asked for
1.0.5 to reach `main`. The repository whose authority file requires
encryption names its method in its Credentials setting when it takes 1.0.5.

### Prepare The Repository To Go Public

**Slug:** `go-public`
**Status:** DONE
**Opened:** 2026-09-26
**Closed:** 2026-09-27

MrFieldTech, 2026-09-26: Claude-Kit is to be made public, so any session can check
and take updates without attaching it. They would rather the repository hold no direct reference to their other projects. The only one in the tree is the list of
project terms in `check.sh`, which guards the kit-owned files against a
project's details leaking in. Keep the guard, but move the list out of the
repository into a GitHub Actions secret, add a generic guard against
addresses that needs no list, and bring `README.md`, `CLAUDE.md` and the state
files up to date for a public repository. MrFieldTech changes the visibility.

**Done, 2026-09-26.** `check.sh` no longer holds the list. It reads the
`KIT_PRIVATE_TERMS` secret in CI, or an untracked `.private-terms` file
locally, and skips the name check with a notice when it has neither. A new
pattern check refuses web addresses, email addresses and host names in
kit-owned files with no list at all. Each guard was made to fail on purpose,
and the current kit passes the old list. `README.md`, `CLAUDE.md` and
`HANDOFF.md` now describe a public repository.

What is left is MrFieldTech's: the secret, so CI checks names again, and the
visibility. The task closes when both are done.

**Done, 2026-09-26, second session.** MrFieldTech chose to leave the history
as it is, and to have the repository's own files name the owner by the
account, so `CLAUDE.md`, `TASKS.md` and `HANDOFF.md` now say MrFieldTech. The
secret is optional: without it CI skips the name check and says so, and the
address check still runs.

**Done, 2026-09-27.** A review of every commit, every version of every file
and every pull request description found no credential, key, password,
private address or surname. From its findings, at MrFieldTech's request:
release 1.0.4 has `kit.sh update` name the source it fetches and runs and
pass it to `git clone` after `--`, and the update prompt in `README.md` has
the session confirm that source first, which works from every earlier
`kit.sh`; an update from 1.0.2 to 1.0.4 was tested. `check.sh` fails when a
pattern cannot be searched rather than passing. CI runs with a read-only
token and a pinned checkout action. Both prompts in `README.md` say to paste
them only into your own repositories. Two sentences that pointed at the old
list in the history came out of this file and `HANDOFF.md`, and fourteen
pull request descriptions now name MrFieldTech. MrFieldTech keeps the
history, including the company address on the merge commits.

Closing this task, GitHub declined recreating `preview` with
`GH007: Your push would publish a private email address`: MrFieldTech had
turned on email privacy, and `main`'s head was a merge made under the old
address. The branch was created through the GitHub API instead, and 1.0.4's
`session-close` now does the same when the push is declined.

**Closed, 2026-09-27.** MrFieldTech made the repository public. GitHub
reports it as not private, and its page loads for a visitor who is not
signed in.

### Pilot The Kit In A Second Repository

**Slug:** `first-pilot`
**Status:** DONE
**Opened:** 2026-09-24
**Closed:** 2026-09-26

MrFieldTech runs the first install outside the repository the skills came from, in a
fresh session on the second repository they chose, with Claude-Kit attached to
the session because it is private. They say the install prompt in
`README.md`. The first run should settle its Session Settings, asking only
what it cannot, remove the response-format section its existing `CLAUDE.md`
repeats from `HOUSE.md`, and push its first task branch.

Each defect the pilot finds is fixed here on this task's branch, released as a
patch version, and taken by `kit.sh update` in every repository that has the
kit. Record here what the pilot found, without naming the repository.

**Found, 2026-09-24.** The first attempt stopped before anything was
written, on two gates in front of the install, and asked MrFieldTech three
questions rather than work around them.

1. Auto mode's classifier blocked `kit.sh install` as `[Self-Modification]`,
   because it writes into `.claude/skills/`. The rule is a soft block, and
   `claude auto-mode defaults` says it clears only when the owner's message
   names the configuration change as wanted. The install prompt only said
   "install". Allow rules cannot clear it: they do not pre-approve writes into
   `.claude/`, and one would have to be written there.
2. The cloud session's instructions allow a push only to the branch it was
   assigned, and the first run pushes `task/kit-setup`. The session asked
   which to use. Once the kit is installed, `HOUSE.md` settles it, but the
   first run reads `HOUSE.md` too late.

Both are fixed in `README.md`, not in a kit-owned file, so there is no
release: the install prompt now names the writes into `.claude/` and
`CLAUDE.md` as wanted and gives permission to push the `task/` branch, says
why, and gives Accept edits mode as the fallback.

**Found, 2026-09-25.** The second attempt, with the fixed prompt, got past
the classifier, installed 1.0.0, named `task/kit-setup` as the branch it
would push, and stopped at six questions. MrFieldTech's answers, and what they
changed in 1.0.1:

1. The Owner was asked, with two names to choose from. MrFieldTech: the Owner is
   a placeholder for whoever answers, and is set without asking. It is now
   the account in the repository's remote URL.
2. The integration branch was asked, because the repository's contributing
   guide releases from `main`. MrFieldTech: `preview`, without asking. It is now
   asked only when a `preview` branch already exists.
3. The checks CI runs need a tool the container lacked, so the session asked
   whether to list them. Listed, they would fail at every close and park
   every task. Checks before merge now holds only commands the container
   runs, and CI runs the rest.
4. The existing `CLAUDE.md` repeated `HOUSE.md`'s response format. MrFieldTech:
   there should be no duplicate. A section that only repeats `HOUSE.md` is
   now removed without asking.
5. The repository's `.gitattributes` would let a Windows checkout give
   `kit.sh` CRLF endings, which bash cannot run. A fix in one repository
   reaches no other, so each kit directory now carries its own
   `.gitattributes`. A scratch clone with `core.autocrlf=true` confirmed it.
6. The contributing guide's file list did not name the kit's files. MrFieldTech:
   add them. The first run now does, without asking.

The environment's end-of-turn hook also told the session to commit the
uncommitted install to its assigned branch while it waited for answers. The
session refused on its own judgement. `session-open` now says to.

MrFieldTech also asked for a shorter install prompt, and `README.md` has one.

**Found, 2026-09-25, third attempt.** With 1.0.1 and the shorter prompt, the
session attached and cloned the kit, installed it, settled every setting
without asking, removed the repeated response-format section, added the
kit's paths to the contributing guide, and pushed `task/kit-setup` without
touching its assigned branch. Auto mode blocked registering the kit's clone
as a repository of the session, which did no harm, and `README.md` now says
that registration is not needed. MrFieldTech's review of its reply, fixed in 1.0.2:

1. The reply listed every Session Setting, which the people reading it do
   not need. It no longer lists them.
2. Automatically delete head branches was asked as a question. The workflow
   needs it, so it is now an `Action needed:` notice.
3. The session asked whether the contributing guide's release step, which
   pushes straight to `main`, or the kit's rule should hold. MrFieldTech: a
   project file that contradicts the kit rightly needs the owner's answer.
   The first run now asks this by rule rather than by the session's own
   judgement.

**Where it stands.** 1.0.2 is on `preview`. The pilot repository has 1.0.1
on its `task/kit-setup`, its session waiting on MrFieldTech's answer about the
release step. MrFieldTech, 2026-09-25: 1.0.2 goes to `main`, and the pilot
repository is rolled back and installed again with it rather than carried on
to `/session-close` on 1.0.1.

**Found, 2026-09-25, fourth attempt.** With 1.0.2 and the 1.0.1 prompt, auto
mode blocked the session's first step, attaching the kit's repository, as
`[Untrusted Code Integration]`. The first three attempts attached it with the
same kind of prompt, so the classifier does not decide the same way every
time. `claude auto-mode defaults` says the rule is a soft block that clears
when the owner names the external source being integrated. The session
changed nothing, refused to fetch the kit another way, and asked. The
install prompt in `README.md` now calls the repository the owner's own and
names running its `kit.sh install`, and the README says how to answer a
session that stops on a block. No kit-owned file changed.

**Found, 2026-09-25, fifth attempt.** With the prompt that named the kit as
the owner's source, the session attached, cloned and registered the kit, read
it, surveyed the repository, and was blocked at `kit.sh install` by the
server-side classifier, which gave no reason. The session stopped, changed
nothing, and offered the exact sentence to approve the command. Of five
attempts, two were blocked at the installer, one at attaching the kit, and
two passed, so no wording makes the install certain. MrFieldTech, 2026-09-25:
install sessions stay in Auto mode and a block is answered when it happens,
and the prompt may be as long as it needs, because it is pasted from the
README. The prompt is now one numbered step per action the classifier
reviews, and asks the session to stop with the approving sentence when a
step is blocked anyway. No kit-owned file changed.

**Found, 2026-09-26, sixth attempt.** With the rebuilt prompt, the install
went through with no block, and the first run settled every setting, asked
only about the contributing guide's release step, which pushed straight to
`main`, and pushed its first task branch. MrFieldTech answered to change the guide.
`/session-close` then marked the task done, created `preview`, merged into it
and on into `main` as asked, after CI passed on both pull requests, and GitHub
deleted both branches. The repository is on 1.0.2 with only `main` left.
MrFieldTech's review, fixed in 1.0.3:

1. The status block came out broken apart. It is now one fenced block with no
   backticks inside.
2. The close took about seventeen minutes: CI ran in full on both pull
   requests, and the session waited on a check-in sixteen minutes out. MrFieldTech:
   recheck about once a minute if that costs little, which it does, and skip
   the second run when nothing changed. `session-close` now does both.
3. The session log row said the task reached `preview`, not `main`. It now
   records a merge into the default branch the owner asked for.
4. MrFieldTech asked whether a repository updates itself. It does not, by design:
   `session-open` reports a newer release, and `README.md` now has the update
   prompt.

**Closed, 2026-09-26.** The kit installs and runs a full round in a second
repository. The pilot repository takes 1.0.3 by the update prompt when MrFieldTech
asks.

### Build The First Release

**Slug:** `release-1-0`
**Status:** DONE
**Opened:** 2026-09-24
**Closed:** 2026-09-24

MrFieldTech, 2026-09-24: the session skills they run in one repository should work in any of their repositories. A repository that has never used them gets a
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

**Decided by MrFieldTech, 2026-09-24.** 1.0.0 reaches `main` before the pilot, so the
pilot installs by the command in `README.md`. No permission rule is added for a
headless `claude` session: the pilot and their own sessions in real repositories
are the fresh-session tests. At close they asked for everything to reach `main`.

The pilot is `first-pilot`.
