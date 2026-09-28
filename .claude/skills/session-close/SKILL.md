---
name: session-close
description: >-
  Close out a Claude Code session in a repository that uses Claude-Kit. For each task branch the session worked on, stops at a clean boundary, places every credential, updates the task's block in TASKS.md and edits HANDOFF.md in place, runs the repository's Regenerate commands, and pushes the branch. A task that is DONE or BLOCKED then merges into the integration branch by pull request and GitHub deletes its branch; a task stopped partway stays parked on its branch. Merges the integration branch into the default branch only when the owner asks. Reports where to see each task's work. Runs only when the owner invokes /session-close.
disable-model-invocation: true
---

# Session Close

Leave the repository so a session with no memory of this one resumes from
committed files alone. Nothing is done until it is pushed. A handoff that
describes work sitting only in the working tree is worse than no handoff,
because the next session trusts it.

This skill names no value that differs between repositories. Each one is in the
`## Session Settings` section of `CLAUDE.md`, and `.claude/kit/HOUSE.md` holds
the rules this skill applies. Below, the owner, the authority file, the default
branch and the integration branch are what Session Settings says they are.

Every session works on task branches, `task/<task-slug>`. Close each task
branch this session worked on, one at a time, by steps 1 to 8. Most sessions
have one. Then do steps 9 to 11 once.

## 1. Stop at a clean boundary

Do not begin new work. Finish only the file or step already in progress. If it
cannot be finished cleanly, leave it and record exactly where it stopped,
naming the file and the section.

Half-finished work described accurately is fine. Half-finished work described as
complete is the failure this skill exists to prevent.

## 2. Place every credential

Before anything is committed, account for every credential this session
produced, was given, or found sitting somewhere it should not be.

First confirm the repository's visibility through the session's GitHub
access. Then:

- **When the repository is confirmed private and the Credentials setting names
  a place or a rule,** such as a section of the authority file, follow it for
  each value. Where it sends a value to a file the repository does not
  commit, or to a store outside the repository, name that place in the
  handoff and never the value. Where it sends a value into a file the
  repository commits, `HANDOFF.md` included, encrypt the value by the method
  the setting names and commit only what the encryption prints. Check that
  the output does not contain the value before it is written anywhere.
- **Otherwise,** when the setting is `none`, or the repository is public, or its
  visibility cannot be confirmed, or a value bound for a committed file has no
  encryption method named or none this session's container can run, commit
  the value nowhere, `HANDOFF.md` included. Put it in the final report under
  its own heading, labelled with what it unlocks, and say plainly that the
  report is the only copy, so the owner can place it before the conversation
  ends. When a method was named but could not run, say why.

Never commit a value in plaintext. Never mask, truncate, or substitute a
reference where a value is recorded, in the report or in a file. Encrypting a
value by the setting's method is not masking it. A value that spans more than
one line, such as a private key or an encrypted block, is recorded whole in a
fenced code block of its own, exactly as it is: never joined onto one line,
wrapped, or re-indented, and never inside a table. Never leave a value only in
the conversation without saying so.

## 3. Update the task's block in TASKS.md

Keep the format the file already has: its frontmatter if it carries one, as the
State file format setting describes, and the named headings under Format below.
Set an `updated` field to today if there is one. Edit this task's block, and the
block of any task this session opened or changed, and nothing else. Another
session may be editing the rest.

Set the status:

- `DONE` when the work is finished. Move the block from Open Tasks to Closed
  Tasks and add a `Closed:` date. The merge in step 8 is what makes it true, and
  if that merge does not happen, step 8 sets it back.
- `BLOCKED` when it needs something only the owner can supply, with the question
  written out and a `Blocked:` line naming what would unblock it. Say in the
  block what is already done, because with an integration branch that work
  merges into it.
- `ACTIVE` when it stopped partway. The block carries the exact stopping point
  and the next action, naming files and functions rather than intentions, and
  whatever context a fresh session needs to continue. `/session-open
  <task-slug>` resumes from exactly this.

## 4. Edit HANDOFF.md

Edit the file in place and never replace it, because another session may close
into it. Change only what this session produced or settled. Keep its format and
the named headings below, in this order, and add nothing else.

- **Purpose.** Unchanged between sessions.
- **Session Log.** Add one row for this task: the date, the task slug and where
  it ended, merged or parked, and the commit range of this session's work on its
  branch. Never the handoff commit's own hash or the pull request number, which
  do not exist when the row is written. When the owner asked in this session
  for the merge into the default branch, the row says the task went there too,
  and if step 9 cannot make that merge, its report says so. Keep the last ten
  rows and drop older ones.
- **Blocked On.** Add, change or remove the row for any task this session
  blocked or unblocked.
- **Credentials In Transit.** Values held here only when the Credentials
  setting sends them here, each encrypted by step 2 and never in plaintext,
  with a label, the method that encrypted it, and the task that will place it.
  Each value is whole in a fenced code block of its own. Otherwise `None`. If
  the file has a `has_secrets` field, set it to match.
- **Decisions Made.** Add the decisions taken this session that are recorded
  nowhere else, each with its reasoning in one line. A decision that governs
  future work belongs in the authority file, or in `CLAUDE.md` when there is
  none, so move it there and note the move here. Mark a decision this session
  overturned as superseded rather than deleting it.
- **Open Questions For the owner,** under the heading that names them. Add
  direct questions, each answerable in a sentence and carrying the context
  needed to answer it without reading the rest of the file, and remove the ones
  this session answered. A question that belongs to one file is a `TODO:` in
  that file, and is not repeated here.
- **Flagged As Unverified.** Add anything assumed, inferred, or believed but not
  checked, each with what would verify it, and remove what this session
  verified.

Never include anything a script generates, such as counts or coverage. Never
include the narrative of the session, restatements of the authority file or
`HOUSE.md`, or optimism such as "nearly finished". Where a task stopped belongs
in its block in `TASKS.md`, not here.

## 5. Regenerate derived files

Run each Regenerate command, in the order Session Settings gives. If any command
fails, record the exact command and the exact error under Flagged As Unverified
and continue. With `Regenerate: none`, skip this step.

## 6. Make the handoff commit

Stage only `TASKS.md`, `HANDOFF.md`, and the paths under Generated files. Commit
them together with a message beginning exactly `handoff: ` followed by a short
description of what moved.

No other commit may begin with that prefix.

## 7. Push the task branch

```
git push -u origin task/<slug>
```

If the push fails on the network, retry up to four times backing off 2, 4, 8
and 16 seconds, then stop and report the error. The branch is the only copy of
the work until it is pushed.

A task that is `ACTIVE` is now parked, and this is its last step. Confirm
`origin/task/<slug>` matches local `HEAD` and the working tree is clean, then go
on to the next task branch or to step 9.

## 8. Merge a finished task

A task that is `DONE` or `BLOCKED` merges into the integration branch. With
`Integration branch: none`, a `DONE` task merges into the default branch and a
`BLOCKED` one parks, below, because its partial work would otherwise reach
production. Below, the target is the branch the task merges into.

A merge needs a pull request, so first confirm the session can open one,
through a GitHub connector or the `gh` command line. If it cannot, park the
task, below, write in its block that the merge waits only on a pull request,
and say so in the report. Change nothing on the remote but the task branch.

**Bring the base in.** When there is an integration branch and it does not
exist on the remote, GitHub deleted it after it merged into the default branch.
Create it again at the default branch's head, which adds no commit to it:

```
git push origin origin/<default branch>:refs/heads/<integration branch>
```

GitHub declines that push, as one that would publish a private email
address, when the owner keeps their address private and the default branch's
head is a merge made under it. Then create the branch through the session's
GitHub access instead, from the default branch, which publishes nothing new.

Then merge it into the task branch, and note the hash of `origin/<target>`
that this brings in, because step 9 compares against it:

```
git fetch origin
git merge --no-edit origin/<target>
git merge --no-edit origin/<default branch>
```

If a merge conflicts, apply the conflict rule in `.claude/kit/HOUSE.md`. The
paths under Generated files are never merged by hand: take either side, run the
Regenerate commands again, and stage what they write. Where both sides only
added lines to `TASKS.md` or `HANDOFF.md`, keep both. For anything else, run
`git merge --abort` and park the task, below. Do not resolve a content conflict
unattended.

**Check the tree.** Run the Regenerate commands, then each command under Checks
before merge, then `git status --short`. If a check fails, park the task. If the
Regenerate commands rewrote a generated file, commit it. Push the task branch.

**Open and merge the pull request.** Through the session's GitHub access, open
a pull request from `task/<slug>` into the target, titled after the task, with
a body naming the task slug and what it changed. Wait for every check run
GitHub reports on the pull request to finish. A combined commit status that
reads `pending` with no statuses behind it means nothing posted one, not that
something is still running.

Checks can run for many minutes. Stay with the pull request until they
finish, reading them again about once a minute. When the session can schedule
a message back to itself, wait by a check-in a minute or two out, which ends
the turn, and carry on from here when it arrives. Never read the checks back
to back, and never set the check-in far out, which leaves the merge idle long
after the checks finish. Tell the owner nothing between readings unless a
check fails.

When the Task preview address is set, the host usually posts the branch's
preview address on the pull request once the branch builds. If it is not the
Task preview address with this slug in it, report the address the host gives and
record the difference under Flagged As Unverified.

- Every check passes: merge it with a merge commit, never a squash, so each step
  of the task stays in the history.
- GitHub reports it cannot be merged because the target moved: bring the base in
  again from the top of this step.
- A check fails: fix it on the task branch and push, and the pull request
  re-runs. If it cannot be fixed in this session, close the pull request
  unmerged and park the task.

Never leave a pull request into the integration branch open at the end of a
session. GitHub retargets an open pull request at the default branch when it
deletes the branch that pull request was aimed at, which is what happens to the
integration branch after every merge into the default branch.

**Confirm the branch is gone.** GitHub deletes the task branch when its pull
request merges, when its Automatically delete head branches setting is on:

```
git fetch origin --prune
git ls-remote --heads origin task/<slug>
```

The second command prints nothing when the branch is gone. If it is still there,
report it for the owner to delete, and say on the `Branch:` line that
Automatically delete head branches is off and needs turning on.

**To park a task instead,** set a `DONE` task back to `ACTIVE` and move its
block back to Open Tasks, or leave a `BLOCKED` task as it is. Write in the block
why the merge did not happen, naming the conflicting files or the failing check.
Commit, push, and report it as parked.

## 9. Merge into the default branch only when the owner asks

Merging the integration branch into the default branch is a separate decision,
and it is the owner's, not this skill's. With `Integration branch: none` there
is nothing to do here.

Do nothing here unless the owner asked for the merge in this session. Do not
infer it from the queue being empty, from the work looking finished, or from
time passing.

When they have asked, check all three before touching anything:

1. Every check passed on the code the integration branch holds. With no
   checks to wait for, that is already true when all three of these hold:
   - The integration branch's head is the merge commit of a task pull request
     this session merged in step 8, after all its checks passed.
   - That commit's first parent is the hash step 8 noted, so nothing else
     merged into the integration branch in between:
     `git rev-parse origin/<integration branch>^1`
   - The default branch holds nothing the integration branch lacks:
     `git merge-base --is-ancestor origin/<default branch> origin/<integration branch>`

   The pull request into the default branch then holds exactly the code those
   checks passed on, and running them again tests nothing new. Otherwise, wait
   for every check GitHub reports on the integration branch's head, as step 8
   waits.
2. The integration branch merges into the default branch with no conflict.
3. No task is `ACTIVE` in `TASKS.md` on the integration branch. A task branch
   merges only when its task is `DONE` or `BLOCKED`, so this always holds unless
   something merged that should not have.

If any check fails, name which one and stop. Do not merge to tidy the branch.

When all three pass:

1. Open the pull request from the integration branch into the default branch,
   titled after what it carries, with a body listing the tasks closed since the
   last merge.
2. Merge it with a merge commit: at once when check 1 held with no checks to
   wait for, otherwise once every check on the pull request passes, waiting as
   step 8 waits.
3. GitHub deletes the integration branch. That is expected. The default branch
   now holds everything it did, and the next task to merge creates it again.

Parked task branches are untouched by this merge and need nothing done to them.
Never push to the default branch directly, and never merge a pull request
someone else opened.

## 10. Check for strays

```
git fetch origin --prune
git branch -r
```

Anything besides `origin/HEAD`, the default branch, the integration branch, the
Other branches, and `origin/task/<slug>` for a task in `TASKS.md` is a stray.
Report each with the count of commits it holds that the default branch does
not. A session cannot delete a branch, so leave strays for the owner.

## 11. Report

Do not summarize the handoff. Reply with exactly these lines and nothing else,
as one fenced code block with no backticks inside it, giving one `Task:`,
`Branch:` and `Preview:` line to each task branch the session closed:

```
Task:    <task slug>, <DONE | BLOCKED | ACTIVE>
Branch:  <merged into <target> by <pull request URL>, deleted by GitHub | merged into <target> by <pull request URL>, not deleted: turn on Automatically delete head branches | parked at <hash>>
Preview: <the Task preview address when parked | the Integration preview address when merged | none>
Commit:  <handoff commit hash>
Secrets: <none | where each value was placed | N in this report for the owner to place>
Parked:  <none | every parked task slug, which is what /session-open takes to resume>
Strays:  <none | branch names>
Merged:  <integration branch into default branch pull request URL, or not requested>
```

A value that could not be committed, by step 2, follows these lines under its
own heading, in a fenced code block of its own when it spans more than one
line, and is the one exception to "nothing else".

A parked task's preview address serves the newest build of its branch. A
merged task's work is on the integration preview once the host has built the
merge, a few minutes after it.

---

## Format

`TASKS.md` and `HANDOFF.md` keep the format they already have. The State file
format setting names it: `kit templates` for the files in
`.claude/kit/templates/`, or a rule in the authority file, such as frontmatter
the repository requires. Either way the headings are these, named and never
numbered.

`HANDOFF.md`:

```markdown
# Session Handoff

## Purpose
## Session Log
## Blocked On
## Credentials In Transit
## Decisions Made
## Open Questions For <Owner>
## Flagged As Unverified
```

`TASKS.md`:

```markdown
# <Title>

## Purpose
## How Tasks Are Worked
## Open Tasks
### <Task Title>
## Closed Tasks
### <Task Title>
```

Each task heading is its title. Directly under it:

```markdown
**Slug:** `<task-slug>`
**Status:** TODO | ACTIVE | BLOCKED | DONE
**Opened:** <YYYY-MM-DD>
**Blocked:** <what would unblock it, only when BLOCKED>
**Closed:** <YYYY-MM-DD, only when DONE>
```

Then the detail block as prose. Task slugs are unique and permanent, and a task
is never renumbered because it carries no number. The slug is also the task's
branch name, `task/<task-slug>`.

Where a task stopped is written in its own block, never in `HANDOFF.md`.

Never use an em dash.
