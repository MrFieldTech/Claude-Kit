# Session Handoff

## Purpose

The state above any one task that a fresh session needs. `session-close` edits
this file in place at the end of every session and `session-open` reads it at
the start of the next, so a session with no memory of the last one picks up
from committed files alone. Where each task stopped is in its own block in
`TASKS.md`, not here, because sessions on different tasks can close into this
file at the same time.

## Session Log

| Date | Tasks touched | Work commits |
|---|---|---|
| 2026-10-12 | `secrets-self-sufficient`, ACTIVE, parked: opened from a private repository taking 1.4.0, with the owner's four decisions and the first round of open decisions in its block | `e3c86fe..083f57b` |
| 2026-10-12 | `age-secrets`, DONE, merged into `preview` and then `main` at MrFieldTech's request: release 1.4.0 makes age encrypted `<slug>.secrets.md` files the kit standard for credentials | `471e2b4..c5c5162` |
| 2026-10-11 | `workflow-practices`, DONE, merged into `preview` and then `main` at MrFieldTech's request: release 1.3.0 folds five practices and a pull request body into the session protocol | `c5394a9..f342a7b` |
| 2026-10-01 | `preview-promotion`, DONE, merged into `preview` and then `main` at MrFieldTech's request: release 1.2.0 lets a temporary session promote the integration branch | `c5d170a..19e297c` |
| 2026-09-30 | `readme-version-update`, DONE, merged into `preview`: the README's update block names the current release, and `check.sh` holds it to `VERSION` | `b7e7ae1..067e760` |
| 2026-09-30 | `add-session-temp`, DONE, merged into `preview` and then `main` at MrFieldTech's request: release 1.1.0 adds `/session-open temp` | `db3756b..d48c4d3` |
| 2026-09-28 | `multi-line-secrets`, DONE, merged into `preview` and then `main` at MrFieldTech's request: release 1.0.5 never commits a credential in plaintext | `3e8aa5b..a1a2427` |
| 2026-09-27 | `go-public`, DONE, merged into `preview`: the repository is public | none, the handoff alone |
| 2026-09-27 | `go-public`, BLOCKED, merged into `preview`: the pre-public review's fixes, with release 1.0.4 | `d5ef770..ef64e39` |
| 2026-09-26 | `go-public`, BLOCKED, merged into `preview`: the repository's own files name the owner MrFieldTech | `e0c3699..4d5c913` |

## Blocked On

None.

## Credentials In Transit

None. A value is held here only when the Credentials setting in `CLAUDE.md`
sends it here, and only encrypted by the method that setting names. In this
repository it never does.

## Decisions Made

- **The kit is vendored, not a plugin and not account-level skills.** MrFieldTech,
  2026-09-24. Each repository holds a pinned copy, so it resumes from
  committed files alone, a kit change reaches it as a reviewable diff, and the
  command names stay `/session-open` and `/session-close`. A plugin cannot
  carry `CLAUDE.md` and would put the protocol governing a repository outside
  it. Skills held on an account sit outside git and go stale unseen.
- **The house rules are imported by `CLAUDE.md`, not carried in a skill.** A
  skill's text loads only when invoked and can be compacted away, and the
  response rules govern every turn. The import was confirmed to load in a
  headless session on 2026-09-24.
- **The integration branch is a per-repository setting, `preview` by
  default.** MrFieldTech, 2026-09-24. The rule that the default branch moves only
  when the owner asks then holds everywhere unless a repository opts out.
- **1.0.0 reached `main` before the pilot.** MrFieldTech, 2026-09-24, so the pilot
  installs by the command in `README.md` rather than from a task branch.
- **No permission rule for a headless `claude` session.** MrFieldTech, 2026-09-24.
  The pilot and the owner's own sessions in real repositories are the fresh-session
  tests.
- **The first run settles the Owner and the integration branch without
  asking.** MrFieldTech, 2026-09-25. The Owner is a placeholder for whoever answers,
  so it is the account that owns the repository, and the integration branch
  is `preview`. Either is changed in `CLAUDE.md` afterwards.
- **A `CLAUDE.md` section that only repeats `HOUSE.md` is removed.** MrFieldTech,
  2026-09-25: there should be no duplicate, because two copies drift apart.
- **An install session stays in Auto mode, and a block is answered when it
  happens.** MrFieldTech, 2026-09-25. Accept edits mode never blocks but makes every
  command that is not read-only wait for approval. The session stops and
  gives the sentence that approves the blocked action.
- **The install prompt may be as long as it needs.** MrFieldTech, 2026-09-25. It is
  pasted whole from `README.md`, and a short one does not clear auto mode.
- **`session-close` rechecks a pull request about once a minute and skips a
  second run of checks that already passed on the same code.** MrFieldTech,
  2026-09-26. Each recheck is a short turn on cached context, and the second
  run on the pull request into the default branch tested nothing new.
- **A repository never updates the kit itself.** An update changes the rules
  a session runs on, so it is the owner's call, taken by the update prompt in
  `README.md` as its own task.
- **Files here are written as if the repository were public.** It was asked
  for as public and created private. Nothing the kit installs names a
  project, so making it public later needs no cleanup first.
- **The repository is public.** MrFieldTech, 2026-09-26, so any session can check
  and take updates without attaching it. The list of project terms moved out
  of `check.sh` into the `KIT_PRIVATE_TERMS` secret, because MrFieldTech
  would rather the repository name none of their other projects. The history
  stays as it is, by MrFieldTech's choice.
- **The history stays as it is, including the company address on the merge
  commits.** MrFieldTech, 2026-09-27. The kit is not advertised, and that
  address is not hidden, though the public one is a different address.
- **A credential is committed only encrypted, and only in a repository
  confirmed private.** MrFieldTech, 2026-09-28. Secrets are encrypted in
  transit, by the method each repository's Credentials setting names, and
  encryption does not make a public repository a place for them.
- **A temporary session, `/session-open temp`, answers questions without a
  branch and turns what is worth keeping into tasks.** MrFieldTech,
  2026-09-30. A question-only session should not claim a task. It offers to
  become a task or to open one per topic, the slug comes from the owner or is
  proposed and asked, and a branch for later is a parked task whose block
  carries its background, so it is never a stray.
- **The README's update block names the current release, and every release
  sets it.** MrFieldTech, 2026-09-30. A release already changes the
  repository, so the prompt is pasted as is. The rule is in `CLAUDE.md` and
  `check.sh` enforces it.

- **A temporary session promotes the integration branch when asked, in any
  words, with no keyword.** MrFieldTech, 2026-10-01. Main only takes merges
  from preview, so a promotion cannot conflict and has no resolution to
  record. It leaves no session log line, the pull request is the record, and
  `session-close` step 9 still promotes when asked during a close.
- **Recurring kinds of work are plain files the protocol reaches, not
  skills.** MrFieldTech, 2026-10-11, adopted six skills from a public
  collection and asked that none need a command to remember. Five are
  practices in `.claude/kit/practices/`, named in `HOUSE.md` and run by the
  session skills at fixed points, and the pull request body is written into
  `session-close`. Plain files sit in an existing kit directory, so the
  install is unchanged and no name can collide with a skill a repository or
  harness has. The collection's skills that bring a second work queue, a
  second handoff or a second branch model were declined.
- **The source collection's license notice is not installed.** MrFieldTech,
  2026-10-11. It names the collection's author, so it stays in `NOTICE.md`
  at the root, and each practice credits the collection without a name.
- **Age encrypted `<slug>.secrets.md` files are the kit standard for
  credentials.** MrFieldTech, 2026-10-11. The setting `kit standard` is the
  default, and a repository keeps its own method by naming it, because one
  of the owner's private repositories already ran the process and it should
  be the same everywhere. A public repository still commits no credential.
- **Every repository uses the kit for whatever the kit supports, unless it
  has a use case that needs otherwise.** MrFieldTech, 2026-10-12. The
  private repository whose process became the standard keeps its own script
  until the owner updates its kit and switches it by hand.

## Open Questions For MrFieldTech

- **Should grilling write each round into the task's block before asking
  it?** `grilling.md` says every open question is written out in the block,
  but only when the session stops. In the session that opened
  `secrets-self-sufficient`, the first round was asked only in the reply and
  reached the block after the owner asked where the questions lived. Asking
  a round only after it is committed would have prevented that. Open a task
  for it?

- **Should the kit make every remote branch tracked from the start?** A
  session working from a single-branch clone pushed its task branch, but git
  recorded no `origin/task/<slug>`, so the cloud end-of-turn hook reported
  the branch as unpushed and `session-close` step 7's check that
  `origin/task/<slug>` matches `HEAD` had nothing to compare. Setting
  `remote.origin.fetch` to every branch in `session-open` step 1 would
  prevent it. This is a change to a kit-owned file. Open a task for it?
- **Should `check.sh` refuse to run on uncommitted kit-owned changes?**
  Section 5 installs from a clone of `HEAD`, so run before committing it
  failed with "status after install reads '1.2.0, current', not '1.3.0,
  current'", which reads as a broken installer rather than "commit first".
  Open a task for it?

## Flagged As Unverified

**No repository has kept a credential by `kit standard` yet.** `check.sh`
section 6 tests `secrets.py` in a scratch repository. The steps `secrets.py
steps` prints for Windows Command Prompt and for macOS or Linux have not been
run on either. The first repository to take 1.4.0 and store a value verifies
them.

**No session has grilled a new task or diagnosed a failure under 1.3.0.**
The close of `workflow-practices` ran the new pull request body and the
retrospective. The first task opened under 1.3.0 tries the grilling, and the
first failing check or Regenerate command tries the diagnosis.

**No temporary session has promoted the integration branch.** 1.2.0 was
checked by `check.sh` only. The first promotion asked for in a
`/session-open temp` session verifies that it waits for the checks on the
integration branch's head and commits nothing.

**No session has run 1.0.3's close.** The sixth pilot attempt ran a full
round on 1.0.2 on 2026-09-26. The once-a-minute recheck and the skipped second
run of checks are untested.

**Whether the update prompt works as one message.** It starts with
`/session-open` and carries the instructions on the lines after it. Whether
Claude Code passes those lines to the skill has not been tried.

**How often the rebuilt install prompt passes auto mode without a block.**
It passed in the sixth attempt, its first use. The fifth attempt was blocked
by the server-side classifier with no reason given, on a prompt that named
the source, so one pass does not show it always holds.

**Whether Accept edits mode lets a cloud session's owner approve the install.**
The permission-modes documentation says a cloud session's Accept edits mode is
`default` mode, where a shell command outside the read-only set prompts.
Nobody has tried it. A pilot that falls back to it verifies it.

**Whether a skill installed partway through a session is listed before the
next session starts.** The install prompt in `README.md` says to follow the
skill rather than run `/session-open`, so the first run works either way.

**The house rules load by import.** Confirmed in a headless session on
2026-09-24, with no approval prompt. Not yet seen in an interactive session.

**The repository the skills came from has not yet opened a session on the
kit.** Its next `/session-open` should print a `Kit:` line. That report is
item 3 of `release-1-0`.
