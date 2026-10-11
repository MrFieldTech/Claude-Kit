# Credentials

The kit standard for credentials: passwords, tokens, API keys, private keys,
recovery codes, account numbers, and anything else that unlocks something.
It applies wherever the Credentials setting in `CLAUDE.md` reads
`kit standard`. A repository replaces it by naming its own place or rule in
that setting instead, and then nothing here applies to it.

The standard commits credentials only in a repository confirmed private.
`HOUSE.md` says what happens to a value anywhere else: it is committed
nowhere and goes in the reply for the owner to place.

## The files

A credential lives in a `<slug>.secrets.md` file. When it belongs to a file
in the repository that has a slug, such as an entry, a page or a service's
configuration, it sits beside that file under the same slug. When it belongs
to nothing in the repository, it goes in `secrets/` at the root, under a slug
naming the service it unlocks.

````markdown
---
slug: <slug>
updated: <YYYY-MM-DD>
---

**<Label naming what this value unlocks>**

```age
-----BEGIN AGE ENCRYPTED FILE-----
<the value, encrypted>
-----END AGE ENCRYPTED FILE-----
```

<Optional note: where the value is used, why it is recorded, what rotating
it breaks.>
````

- Two frontmatter fields, `slug` and `updated`, and nothing else. `slug`
  matches the filename.
- One bold label per value, and one value per label. The label and the note
  are never encrypted and never hold a value, so anyone can tell what each
  value unlocks without a key.
- Each value is recorded in full before it is encrypted: never masked,
  truncated or replaced by a reference.
- Each value is encrypted on its own, with age, to every public key in
  `secrets-recipients.txt`, and written as an ASCII armored block fenced and
  tagged `age`. A value of more than one line, such as a private key or a list
  of recovery codes, is one value in one block.
- A value in plaintext is a backticked line, or a fenced block not tagged
  `age`. Every one is a failure that `secrets.py check` reports, and
  `secrets.py lock` encrypts it. A value in a table cannot be encrypted, and
  the table is rewritten as one labelled value per block first.

`HANDOFF.md` holds a value only under Credentials In Transit, in the same
form: a bold label and an encrypted block. That is for a value whose
`<slug>.secrets.md` does not exist yet, until a task places it.

`todo_sweep.py` never reads a `<slug>.secrets.md` file.

## The keys

`secrets-recipients.txt` at the repository root holds one age public key per
line, each under a comment naming who holds the private half. A public key
can only encrypt, so the file is committed. Any one matching private key
decrypts every value.

Three keys is the usual set: the owner's own, a recovery key kept apart from
it for whoever continues without the owner, and, when a build or a deploy
reads the values, one held by that host as an encrypted variable. One key
works. A key lost with no other left loses every value in the repository.

A private key is a line beginning `AGE-SECRET-KEY-1`. It is never committed,
never written into a state file, never pasted into a conversation, and never
held by a session. The owner makes each key on their own computer, with
`age-keygen -o <file outside the repository>`, which prints the public key,
and gives the session only that public line.

## The tool

`.claude/kit/secrets.py` does every operation. It needs `python3` and the
`age` command line tool, except `check`, which needs `python3` alone. Run
`python3 .claude/kit/secrets.py --help` for its commands.

| To | Run |
|---|---|
| Store a value | `secrets.py set <file> "<label>"`, the value on standard input. A label already there has its value replaced |
| Store a value the owner encrypted | `secrets.py place <file> "<label>" < <armored file>` |
| Hold a value under Credentials In Transit | `set` or `place` with `HANDOFF.md` as the file |
| Encrypt plaintext already in a file | `secrets.py lock <file>` |
| Print one encrypted block | `secrets.py encrypt`, the value on standard input |
| Check every value is encrypted | `secrets.py check` |
| Give the owner the steps to encrypt on their own computer | `secrets.py steps` |
| Read the values | `secrets.py show <file> --identity <key file>`, on the owner's computer |
| Change who can read | Edit `secrets-recipients.txt`, then `secrets.py rekey --identity <key file>`, on the owner's computer |

A value is never put on a command line, where it lands in shell history.
`set` and `encrypt` read it from standard input, and a session pipes it in
from a file outside the repository or from a heredoc in the command it
runs, never as an argument. After storing a value, search the working tree for it, printing a count
and never the value, and commit only when the count is zero.

`place` refuses a block that is not armored age, is encrypted to a passphrase
rather than to keys, or is encrypted to a different number of keys than
`secrets-recipients.txt` lists. A block encrypted to the right number of the
wrong keys passes `place` and fails the first time a key tries to read it.

## Keeping the plaintext out of the session

A value a session produced or was given is in the conversation already, and
the session stores it with `set`. A value the owner has not yet given is
better never given in plaintext: the session runs `secrets.py steps` and
gives the owner its output whole. The owner encrypts the value on their own
computer, attaches the armored file it writes, and says what it unlocks, and
the session stores it with `place`.

## Reading a value without the kit

age is an open format with more than one implementation. Copy the lines from
`-----BEGIN AGE ENCRYPTED FILE-----` to `-----END AGE ENCRYPTED FILE-----`
into a file and run `age --decrypt --identity <key file> <that file>`.

## Changing a key

When a key is lost, exposed, or passes to someone else:

1. The owner makes a new key with `age-keygen -o <file>`.
2. Replace that key's line in `secrets-recipients.txt`.
3. On a computer holding any current private key, run
   `python3 .claude/kit/secrets.py rekey --identity <key file>`. It
   re-encrypts every value in every `<slug>.secrets.md` file and in
   `HANDOFF.md` to the keys now listed.
4. When a host holds a key as a variable, set the new one there before the
   push.
5. Commit and push.

A removed key still reads every copy made before the rekey, including every
one in the git history. A value that key may have exposed is changed at its
source, not only re-encrypted.

## Setting it up

A repository whose Credentials setting is `kit standard` and that has no
`secrets-recipients.txt` cannot encrypt yet, so a value goes in the reply as
`HOUSE.md` says. The session then puts `Action needed:` at the top of part 1:
make the keys on your own computer and give the session the public line of
each, with who holds it. The session writes `secrets-recipients.txt` from
them on a task branch.

When a container lacks the `age` tool, the session installs it with the
system's package manager if it can, and otherwise puts the value in the
reply and says why.
