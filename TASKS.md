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

### Keep The README Update Prompt On The Current Version

**Slug:** `readme-version-update`
**Status:** ACTIVE
**Opened:** 2026-09-30

MrFieldTech, 2026-09-30: the README's copy and paste block for updating
Claude-Kit in a repository opens with
`/session-open kit-update-<new version with hyphens>`. Make that line name the
version the kit is currently on, and keep it current: every version change
already changes the repository, so it updates the README to the version a
repository can update to as well.

## Closed Tasks

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
