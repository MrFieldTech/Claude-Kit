---
name: session-open
description: >-
  Start a Claude Code session in a repository that uses Claude-Kit. Takes an optional task slug: an existing task resumes on its branch, a slug that names no task starts a new task under that name, and with no slug it lists the parked task branches and queued tasks and asks. In a repository that has never used the kit, it proposes the Session Settings and builds TASKS.md and HANDOFF.md first. Reads the authority file, CLAUDE.md, TASKS.md and HANDOFF.md, reports the kit's version and any stray branch, puts the session on the task's own branch, task/<task-slug>, and works the task from the stopping point in its block. Runs only when the owner invokes /session-open.
disable-model-invocation: true
---

# Session Open

Resume from committed files alone. The owner supplies at most the slug of the
task they want, after `/session-open` or in their message: no hash, no branch
name, no summary of last time. Everything needed is in the repository, and if
it is not in the repository it did not survive, which is a `session-close`
failure to report rather than a gap to fill by guessing.

This skill names no value that differs between repositories. Each one is in the
`## Session Settings` section of `CLAUDE.md`, and `.claude/kit/HOUSE.md` holds
the rules this skill applies. Below, the owner, the authority file, the default
branch and the integration branch are what Session Settings says they are.

Every session works on the branch of one task, `task/<task-slug>`. Run these
steps in order. Do not skip ahead to the work.

## 1. Fetch everything

```
git fetch origin "+refs/heads/*:refs/remotes/origin/*" --prune
```

If `git rev-parse --is-shallow-repository` prints `true`, also run
`git fetch --unshallow origin`. A shallow clone hides the history the later
steps compare against.

## 2. Find the base and read state

**First, is this the kit's first run here?** It is when `CLAUDE.md` has no
`## Session Settings` section and no branch on the remote carries a `TASKS.md`
holding a `**Slug:**` line. Check each remote branch with
`git grep -l '^\*\*Slug:\*\*' origin/<branch> -- TASKS.md`. If it is the first
run, follow First Run at the end of this file and then come back to step 3.

A task branch carrying `TASKS.md` while the default branch does not is a first
task that has not merged yet. That is not a first run. Read the settings and
state files from that branch in place of the base below.

**The base** is `origin/<integration branch>` when it exists. When it does not,
GitHub deleted it after it merged into the default branch, which is the normal
end of a round, and the base is `origin/<default branch>`. With
`Integration branch: none`, the base is always the default branch. Do not
create the integration branch here. The first task to merge creates it.

```
git checkout --detach <base>
```

Read, in this order, as they exist on the base:

1. The authority file, when Session Settings names one. It overrides everything,
   including this file.
2. `CLAUDE.md`, and `.claude/kit/HOUSE.md`, which it imports.
3. `TASKS.md`
4. `HANDOFF.md`

Read `HANDOFF.md` in full. Flagged As Unverified names facts that look settled
and are not, and acting on one of them is how a wrong fact gets written down
and stops being questioned.

**Then check the kit:**

```
bash .claude/kit/kit.sh status
```

It prints the `Kit:` line for step 6: the installed version, whether the kit's
source has a newer one, and any kit-owned file edited in place. Never update
the kit here. An update is the owner's call, made on a task branch in its own
commit with `bash .claude/kit/kit.sh update`. A kit-owned file edited in place
is reported and not reverted, because the edit may be the only copy of a fix
that belongs in the kit.

## 3. Survey the branches

```
git branch -r
```

Sort every remote branch except `origin/HEAD`:

- `origin/<default branch>`, `origin/<integration branch>`, and every branch
  the Other branches setting names are expected.
- `origin/task/<slug>` is a task branch when `<slug>` is a task in `TASKS.md`,
  on the base or on that branch. It is parked, or another session is working it
  right now, and the two look the same from here. Read its task's status and
  stopping point from the branch itself, with
  `git show origin/task/<slug>:TASKS.md`.
- A task branch whose task is `DONE` on the base should have been deleted by
  GitHub when its pull request merged. Report it for the owner to delete and
  carry on.
- Anything else is a stray: a branch by any other name, including one the cloud
  harness assigned to an earlier session, or a `task/` branch with no task
  behind it.

For each stray, report the branch name, the number of commits it has that the
default branch does not, and the files it adds:

```
git log --oneline origin/<default branch>..<branch> | wc -l
git diff --name-status origin/<default branch> <branch> | grep '^A'
```

When there is an integration branch, list the open pull requests into it
through whatever GitHub access the session has, a GitHub connector or the `gh`
command line. There should be none. One left open means a session ended
between opening and merging it, and GitHub would aim it at the default branch
the next time the integration branch is deleted, so report it with the strays.
With no GitHub access, say so on the `Strays:` line.

Report strays and stop until the owner answers. Do not merge them, do not
delete them, and do not start work with the report unread. A stray is the one
failure mode that loses finished work permanently. Two exceptions carry on
without stopping, reported on the `Strays:` line: a stray holding no commit the
default branch lacks, because nothing on it can be lost, and a branch the
owner already answered for in this session's First Run.

## 4. Choose the task

The owner names a task by its slug, after `/session-open` or in their message,
with or without `task/` in front: `/session-open footer-rebuild` and
`/session-open task/footer-rebuild` mean the same. Take the first case that
applies.

**a. They named a task that has a branch.** Resume it.

**b. They named a task in `TASKS.md` that has no branch.** Start its branch. If
the task is `DONE`, ask whether to reopen it or to open a new task under
another slug, and stop until they answer.

**c. They named a slug that is no task.** Open a new task under that slug: a
block under Open Tasks in `TASKS.md` with a title, the slug, status `ACTIVE`,
today's date, and a detail block recording what they asked for. If their
message does not say what the task is for, ask before writing the block. If
the slug breaks the rule below, propose one that keeps it and ask.

**d. They named nothing but asked for new work.** Open a new task for it the
same way, choosing a slug that keeps the rule below.

**e. They named nothing and asked for nothing.** List every task branch with
its task's title, status, stopping point and preview address when there is
one, then every task under Open Tasks that has no branch and is not `BLOCKED`,
and ask whether to resume one, start one, or start something new. With nothing
to list, say so and ask what the new task is. Do not invent work. Stop until
they answer.

A task slug is lowercase letters, digits and hyphens, no longer than the Task
slug limit, unique among tasks, and none of the Reserved slugs.

A task branch the owner did not name or choose is never taken. A parked branch
and one another session is working look the same, and two sessions on one task
is the collision the task branches exist to prevent.

## 5. Get onto the task branch

**If `origin/task/<slug>` exists, resume it:**

```
git checkout -B task/<slug> origin/task/<slug>
git merge --no-edit <base>
git merge --no-edit origin/<default branch>
```

The last merge is a no-op in the usual case and it is cheap. It matters when the
default branch carries a merge that the integration branch does not.

**If it does not exist, create it and claim it:**

```
git checkout -B task/<slug> <base>
git merge --no-edit origin/<default branch>
```

Set the task's status to `ACTIVE` in its block, or add the block for cases c
and d, commit, and push at once:

```
git push -u origin task/<slug>
```

The pushed branch is the claim. A session opening after this one sees the task
as taken. If the push is rejected because the branch now exists, another
session claimed the task first: tell the owner and go back to step 4 without
it.

**If a merge conflicts,** apply the conflict rule in `.claude/kit/HOUSE.md`.
The paths under Generated files are never merged by hand: take either side,
run the Regenerate commands, and stage what they write. Where both sides only
added lines to `TASKS.md` or `HANDOFF.md`, keep both. For anything else, run
`git merge --abort`, report the conflicting file names, and stop until the
owner answers. Do not resolve a content conflict unattended. Both sides are
committed work and picking one loses the other.

Never create a branch by any other name, never commit to the default branch or
the integration branch, and never push the branch the cloud harness assigned.

If a merge in this step changed any file under `.claude/skills/` or
`.claude/kit/`, re-read `.claude/skills/session-open/SKILL.md` and follow the
version now on disk from step 6. If it changed the authority file, `CLAUDE.md`
or `HANDOFF.md`, read them again.

## 6. Report, then work

Report exactly these lines, then continue without waiting for a reply:

```
Task:     <task slug>, <resumed | started from the queue | new>
Branch:   task/<slug> <resumed at <hash> | created from <the base branch's name>>
Preview:  <the Task preview address with the slug in it | none>
Base:     <origin/<integration branch> at <hash> | origin/<default branch> at <hash>, <integration branch> absent>
Kit:      <the line kit.sh status printed>
Parked:   <none | the other task branches, each with its task's status>
Strays:   <none | branch names and any open pull request into the integration branch>
Next:     <the stopping point in the task's block, or its first step>
```

With `Integration branch: none`, the `Base:` line names the default branch
alone. A preview address serves the newest build of the task branch. For a
branch created in this step, the host builds it from the push that claimed it,
so the address works a few minutes later; say so on the `Preview:` line.

Then work the task from its stopping point. Follow its detail block. Do not
re-plan a task the block already specifies and do not ask the owner to
re-confirm anything recorded under Decisions Made.

## While working

Commit as you go and push the task branch after every commit. Until it merges,
it holds the only copy of the work, and the container a cloud session runs in
does not outlive the session. Where the repository builds previews, every push
also rebuilds the task's own.

Never commit to the default branch or the integration branch, never create a
branch other than a task's, and never force push.

A session can work more than one task, one at a time. Before switching, write
the current task's stopping point into its block, commit, and push its branch,
then take the next task by steps 4 and 5. `session-close` closes every task
branch the session worked on.

If a task turns out to be blocked on a decision only the owner can make, mark
it `BLOCKED` in its block with the question written out, add the question under
the Open Questions heading in `HANDOFF.md`, and tell the owner. They decide
whether to close it now or to switch to another task first.

If a credential is produced or discovered, place it before it is forgotten, by
the Credentials setting and the credential rule in `.claude/kit/HOUSE.md`. Do
not leave it only in the conversation without saying so.

Never use an em dash.

## First Run

For a repository that has never used the kit. `kit.sh install` has written the
kit-owned files into the working tree and nothing is committed yet. If
`.claude/kit/kit.sh` is not there, stop and ask the owner to install the kit
first, by the command in the kit's README.

1. **Find the default branch.** Read it from
   `git symbolic-ref --short refs/remotes/origin/HEAD`, or from the
   `HEAD branch:` line of `git remote show origin`. A repository with no
   commits at all has none, and the last paragraph of this section covers it.

2. **Read the repository and propose a value for every Session Settings key.**
   The keys and what each means are at the end of `.claude/kit/HOUSE.md`. Look
   at:
   - `.github/workflows/` and any other CI configuration, for the checks that
     run on a pull request and the commands behind them.
   - The package manifest and build files, such as `package.json`,
     `pyproject.toml` or a `Makefile`, for build, test and lint commands.
   - Any existing `CLAUDE.md`, `README.md` or contributing guide, for the
     owner, rules the repository already follows, and a file that already acts
     as an authority.
   - Hosting configuration and deployment notes, for a preview address per
     branch.
   - Files the repository generates and commits, and the commands that
     regenerate them.
   - Every remote branch. Each one either belongs under Other branches or will
     be reported as a stray from now on.

   A value the repository does not show is a question, never a guess.

3. **Ask.** Show the proposed settings as a list, marking each value as read
   from a file or proposed as a default, and ask about every value that could
   not be read, with lettered options where a few answers are plausible. The
   Owner is always asked unless the repository states it. Stop until the owner
   answers.

4. **Write the settings and state files on the first task's branch.** The
   first task is the one the owner named, or `kit-setup` when they named none.
   Create its branch from the default branch as step 5 does. Then:
   - `CLAUDE.md`. When one exists, keep everything in it: add
     `@.claude/kit/HOUSE.md` as its first line and the Session Settings section
     after its title. Where one of its sections repeats a rule `HOUSE.md` now
     carries, show the two together and ask before removing it. When there is
     no `CLAUDE.md`, start from `.claude/kit/templates/CLAUDE.md`.
   - `TASKS.md` from `.claude/kit/templates/TASKS.md`, with the first task's
     block under Open Tasks.
   - `HANDOFF.md` from `.claude/kit/templates/HANDOFF.md`, with its Open
     Questions heading naming the owner.
   - Whatever the Regenerate commands write, by running them.

   A `TASKS.md`, `HANDOFF.md` or generated file that already exists and was
   not written by the kit is never overwritten unasked. Show it, and ask
   whether to fold it into the kit's format or to move it aside.

   Commit all of it together with the kit-owned files, including
   `.claude/kit/MANIFEST`, and push the branch at once. That push is the claim.

5. **Name what only the owner can set,** as numbered questions in the reply:
   - GitHub's Automatically delete head branches, under the repository's
     Settings, General, Pull Requests. Without it, merged task branches and the
     integration branch pile up, because a session cannot delete a branch.
   - When there is a preview host, `task/*` and the integration branch in its
     list of branches that build previews.

Then return to step 3.

A repository with no commits at all has no default branch, and a pull request
needs a base. Create the default branch with a single commit holding only a
`README.md` that says what the repository is, push it, and carry on from item
2. It is the one commit the protocol makes directly on the default branch, and
the report says so.
