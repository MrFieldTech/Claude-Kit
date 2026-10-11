# Grilling

Settle what a task is before it is written down. A task's block is its
specification, and a block written from a guess is the fluent and wrong
output `HOUSE.md` warns about. Grilling interviews the owner relentlessly
about every decision the task depends on, so the block records decisions
rather than assumptions.

`session-open` runs this before it writes a new task's block, and for any
decision a queued task's block leaves open before its first step. It also
runs whenever the owner asks for a plan, a design or an idea to be
stress-tested, in any words.

## The design tree

Treat the request as a tree of decisions, where each decision opens the
decisions that hang off it. The **frontier** is every open decision whose
prerequisites are already settled: the questions that can be asked now
without guessing at an answer not yet given.

## Facts are the session's, decisions are the owner's

Before asking anything, look up every fact the repository, its state files,
its history or a command can answer. A question to the owner is a decision,
or a fact only the owner holds. A fact that only someone other than the
owner holds goes into a questionnaire, by `questionnaire.md`, and the
decision that waits on it stays open.

A lookup holds up only the questions that wait on it. Ask the rest of the
frontier now, and the waiting questions once the fact is in.

## Rounds

Ask the whole frontier in one round, in the numbered question format
`HOUSE.md` sets. Each question carries the context it needs and the
session's recommended answer, listed first as option `a` and marked
`(recommended)`, so the owner can accept a round with `1a, 2a`, or with
`all recommended`.

Then wait for the answers. Each answer settles a branch and opens the
decisions behind it. Recompute the frontier and ask the next round. A
question whose answer depends on another question in the same round
belongs in a later round.

## Done

Grilling is done when the frontier is empty: every branch visited, nothing
left silently assumed, and the owner agreeing the understanding is shared.
A request that already settles every branch takes no round at all. Say so
in one line and go on.

Every decision goes into the task's block, with the owner's name and the
date, and every question still open is written out there. When the session
has to stop before the frontier is empty, it writes the block anyway with
what is settled, makes the next round its stopping point, and claims and
parks the task as usual, because a decision held only in the conversation
does not survive it.

Adapted under the MIT License from a public collection of agent skills.
`NOTICE.md` in the kit's own repository holds its notice.
