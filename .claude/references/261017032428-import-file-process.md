# Session Reference: Keep A Verbatim Copy Of Each Imported Reference

**Task:** `import-file-process`, DONE at close
**Repository:** MrFieldTech/Claude-Kit
**Developer:** GRM / MRFIELDTECH
**Written:** 2026-10-17 03:24:28 UTC
**Commits:** `94754b0..90bd2f0` on `task/import-file-process`
**Companion:** none

## Current State

Done. Release 1.13.0 keeps a bit for bit copy of each imported reference
and its companion, and of every file uploaded to a task session, under
`.claude/imported/`. Merged into `preview` and promoted to `main` at this
close, at MrFieldTech's request.

## Decisions

- An import copies each reference it imports to
  `.claude/imported/<owner>/<repository>/<reference name>`, in the same
  commit, never edited afterwards. MrFieldTech, 2026-10-17.
- The companion is copied whole beside it, whatever the recipients, and its
  blocks are placed only when the recipients `match`. Where Credentials is
  `none` or the repository is not confirmed private it is not copied, unless
  the developer explicitly says to. MrFieldTech, 2026-10-17.
- An import reads only a source's `.claude/references/`, never its
  `.claude/imported/`. MrFieldTech, 2026-10-17.
- In a public or unconfirmed repository, each reference from a source that
  is not public, and each upload, is asked about: continue or omit.
  MrFieldTech, 2026-10-17.
- Every file uploaded to a task session is copied to
  `.claude/imported/session-import/<name>-<yymmddhhmmss>.<ext>`, `<ext>` the
  last extension except `.secrets.md` kept whole, one UTC time per message,
  then used as any presented file is, never run through the import.
  MrFieldTech, 2026-10-17.
- A temporary session copies nothing unless it opens a task. MrFieldTech,
  2026-10-17.
- An upload of 100 MB or more, one holding a plaintext credential, a
  companion not copied, and one omitted or barred gets a placeholder
  `<name>-<yymmddhhmmss>.md` describing the original, what it held and was
  for, where its data went and why it was not copied, with no credential
  value. MrFieldTech, 2026-10-17.
- This repository never imports from other repositories. MrFieldTech,
  2026-10-17.

## Verified Facts

- `secrets.py rekey` refuses when any block will not decrypt with the key
  given, so a copy encrypted to another repository's keys had to be skipped.
  Source: `.claude/kit/secrets.py`, `cmd_rekey`.
- `secrets.py check` requires a `*.secrets.md` file's frontmatter slug to
  match its file name, which a renamed upload copy cannot. Source:
  `.claude/kit/secrets.py`, `problems_in`.
- The TODO sweep already skips every path under `.claude/`. Source:
  `.claude/kit/todo_sweep.py`, `excluded`.
- `bash check.sh` passed on `4a2f3aa`, including a new test that `check`
  reads a copy under `.claude/imported/` and `rekey` leaves it unchanged.
  Source: the command's output in this session.

## Exact Values

- Release: `1.13.0`
- Upload copy path: `.claude/imported/session-import/<name>-<yymmddhhmmss>.<ext>`
- Import copy path: `.claude/imported/<owner>/<repository>/<reference name>`

## Artifacts

- `.claude/kit/references.md`, new section Copies, and The import's commit
  and Questions rules.
- `.claude/kit/HOUSE.md`, a Copies pointer under State files and the
  companion copy exception in the credential rule.
- `.claude/kit/secrets.py` and `.claude/kit/secrets-decrypt.mjs` skip
  `.claude/imported/`.
- `check.sh`, the copy test and the private-terms scan of
  `.claude/imported/`.
- `CLAUDE.md`, the project rule that this repository never imports.

## Gotchas

- The companion was never copied as a file before 1.13.0: each block was
  placed per label by `secrets.py place`.

## Flagged As Unverified

- No session has made a copy under `.claude/imported/` from the skills.
  Verified by: a file uploaded to a task session, and an import.
- Where Claude Code puts an uploaded file, and how its original name is
  read. Verified by: the first upload to a task session.

## Open Questions

None.

## Credentials

None.

## Subjects

### Claude-Kit

**Slug:** `claude-kit`
**Kind:** project

- Release 1.13.0 adds `.claude/imported/`, the repository's own verbatim
  record of imported references, their companions and uploaded files.
  Source: `CHANGELOG.md`.
