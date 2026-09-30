#!/usr/bin/env bash
# Checks the kit before it merges. Run from anywhere: bash check.sh
#
# 1. No kit-owned file holds an address, or a name on the private list of
#    project terms when one is given.
# 2. No file in the repository holds an em dash.
# 3. The scripts parse, each skill's frontmatter is whole, and every
#    kit-owned directory keeps LF line endings.
# 4. VERSION is a version number, CHANGELOG.md has an entry for it, and the
#    README's update block names it.
# 5. An install into a scratch repository works end to end: the manifest,
#    the status line, the guard against overwriting local edits, and the
#    TODO sweep.
# 6. This repository's own TODO.md is current.
#
# Exits non-zero on the first section that fails, after printing why.

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
KIT_ROOT="$(pwd)"

KIT_OWNED=(.claude/kit .claude/skills/session-open .claude/skills/session-close)

fail() {
  printf 'check: %s\n' "$*" >&2
  exit 1
}

# 1. A kit-owned file is installed into every repository, public or private,
# so it may name no project, person, account, host or address.
#
# Addresses are caught by pattern: a web address, an email address, or a
# host name under a common top-level domain.
ADDRESS='https?://|[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+\.[A-Za-z]{2,}|\b[A-Za-z0-9-]+\.(com|net|org|io|dev|app|gg|co|us|me|ai)\b'
# grep exits 1 when nothing matches and 2 when it cannot search, which must
# fail the check rather than pass it.
status=0
grep -rnIE "$ADDRESS" "${KIT_OWNED[@]}" || status=$?
[ "$status" -ne 0 ] && [ "$status" -ne 1 ] && fail "the address pattern could not be searched"
[ "$status" -eq 0 ] && fail "the lines above hold an address, which belongs to one project"
# Names cannot be caught by pattern, so they come from a list kept out of
# this public repository: the KIT_PRIVATE_TERMS repository secret in CI, or an
# untracked .private-terms file locally, holding one extended regular
# expression. Add a term there whenever a project's detail leaks in. Without
# either, this part is skipped, and CI still runs it on every pull request.
terms="${KIT_PRIVATE_TERMS:-}"
if [ -z "$terms" ] && [ -f .private-terms ]; then
  terms="$(tr -d '\n' < .private-terms)"
fi
if [ -n "$terms" ]; then
  status=0
  grep -rnIE "$terms" "${KIT_OWNED[@]}" || status=$?
  [ "$status" -ne 0 ] && [ "$status" -ne 1 ] && fail "the private terms are not a valid pattern"
  [ "$status" -eq 0 ] && fail "the lines above name something that belongs to one project"
  echo "check: kit-owned files hold no address and name no project"
else
  echo "check: kit-owned files hold no address (no private terms given, so names were not checked)"
fi

# 2. The house rules forbid the em dash, in the kit as everywhere else.
if git ls-files -z | xargs -0 grep -nI $'\xe2\x80\x94' --; then
  fail "the lines above hold an em dash"
fi
echo "check: no em dash"

# 3. Syntax, skill frontmatter, and line endings. A checkout on Windows
# turns LF into CRLF unless .gitattributes says otherwise, and bash cannot
# run kit.sh with CRLF endings.
bash -n .claude/kit/kit.sh
python3 -c 'import ast, sys; ast.parse(open(sys.argv[1]).read())' .claude/kit/todo_sweep.py
for skill in session-open session-close; do
  file=".claude/skills/$skill/SKILL.md"
  [ "$(sed -n 1p "$file")" = "---" ] || fail "$file does not open with frontmatter"
  grep -qx "name: $skill" "$file" || fail "$file does not name itself $skill"
  grep -qx "disable-model-invocation: true" "$file" || fail "$file can be invoked by the model"
  grep -q '^description: ' "$file" || fail "$file has no description"
done
for dir in "${KIT_OWNED[@]}"; do
  grep -qx '\* text eol=lf' "$dir/.gitattributes" 2>/dev/null \
    || fail "$dir has no .gitattributes keeping LF line endings"
done
if grep -rlI $'\r' "${KIT_OWNED[@]}"; then
  fail "the files above hold a carriage return"
fi
echo "check: scripts parse, skills are whole, and line endings stay LF"

# 4. Every release is numbered and recorded.
version="$(tr -d '[:space:]' < VERSION)"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "VERSION holds '$version', not a version number"
grep -q "^## $version\b" CHANGELOG.md || fail "CHANGELOG.md has no '## $version' entry"
grep -qx "/session-open kit-update-${version//./-}" README.md \
  || fail "README.md's update block does not open with /session-open kit-update-${version//./-}"
echo "check: version $version is recorded"

# 5. End to end, in a scratch repository with nothing of its own.
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT
repo="$scratch/repo"
git init --quiet "$repo"
git -C "$repo" -c user.name=check -c user.email=check@example.invalid \
  commit --quiet --allow-empty -m "empty"

# Install from a clean clone of this checkout's HEAD, so uncommitted edits do
# not make the status line disagree with itself.
git clone --quiet "file://$KIT_ROOT" "$scratch/kit"
KIT_SOURCE="$scratch/kit" bash "$scratch/kit/.claude/kit/kit.sh" install "$repo" >/dev/null

for file in $(cd "$scratch/kit" && find "${KIT_OWNED[@]}" -type f | sort); do
  [ -f "$repo/$file" ] || fail "install left out $file"
  grep -q "  $file\$" "$repo/.claude/kit/MANIFEST" || fail "MANIFEST does not list $file"
done
[ -x "$repo/.claude/kit/kit.sh" ] || fail "install left kit.sh without its execute bit"

status="$(cd "$repo" && bash .claude/kit/kit.sh status)"
[ "$status" = "$version, current" ] || fail "status after install reads '$status', not '$version, current'"

printf '\nA local edit.\n' >> "$repo/.claude/kit/HOUSE.md"
status="$(cd "$repo" && bash .claude/kit/kit.sh status)"
case "$status" in
  *"edited locally: .claude/kit/HOUSE.md"*) ;;
  *) fail "status did not report a local edit: '$status'" ;;
esac
if KIT_SOURCE="$scratch/kit" bash "$scratch/kit/.claude/kit/kit.sh" install "$repo" >/dev/null 2>&1; then
  fail "install overwrote a kit-owned file edited in place"
fi
KIT_SOURCE="$scratch/kit" bash "$scratch/kit/.claude/kit/kit.sh" install "$repo" --discard-local-edits >/dev/null
status="$(cd "$repo" && bash .claude/kit/kit.sh status)"
[ "$status" = "$version, current" ] || fail "status after reinstall reads '$status'"

(cd "$repo" && bash .claude/kit/kit.sh update >/dev/null)
status="$(cd "$repo" && bash .claude/kit/kit.sh status)"
[ "$status" = "$version, current" ] || fail "status after update reads '$status'"
echo "check: install, status, and update work"

# The sweep: a question, a statement, a wrapped question, a marker in
# backticks and one in a code fence, and a file the sweep must not read.
cat > "$repo/notes.md" <<'EOF'
# Notes

TODO: Who owns the backup schedule?

TODO: the port number.

TODO: Which host does the nightly job run on, and
who is told when it fails?

The convention is `TODO: <question>`, which is not itself a TODO.

```
TODO: inside a fence, which is an example.
```
EOF
printf 'x = 1  # TODO: Is this still used?\n' > "$repo/code.py"
printf 'TODO: never read?\n' > "$repo/key.secrets.md"
git -C "$repo" add notes.md code.py key.secrets.md
(cd "$repo" && python3 .claude/kit/todo_sweep.py >/dev/null)
expected='# TODO

Generated by `.claude/kit/todo_sweep.py` from every `TODO:` in the repository. Never edit it by
hand: answer each question where it is asked, then run the sweep again.

**4 open, in 2 files.** 1 is not yet written as a question.

## `code.py`

- Line 1: Is this still used?

## `notes.md`

- Line 3: Who owns the backup schedule?
- Line 5: the port number. **Not yet a question.**
- Line 7: Which host does the nightly job run on, and who is told when it fails?
'
[ "$(cat "$repo/TODO.md")" = "${expected%$'\n'}" ] || {
  diff <(printf '%s' "$expected") "$repo/TODO.md" >&2 || true
  fail "the sweep wrote something other than expected, diff above"
}
(cd "$repo" && python3 .claude/kit/todo_sweep.py --check >/dev/null) \
  || fail "the sweep calls its own fresh output stale"
printf 'TODO: A new question?\n' >> "$repo/code.py"
if (cd "$repo" && python3 .claude/kit/todo_sweep.py --check >/dev/null 2>&1); then
  fail "the sweep missed a stale TODO.md"
fi
printf '# My own list\n' > "$repo/TODO.md"
if (cd "$repo" && python3 .claude/kit/todo_sweep.py >/dev/null 2>&1); then
  fail "the sweep overwrote a TODO.md it did not write"
fi
echo "check: the TODO sweep works"

# 6. This repository keeps its own TODO.md by the sweep it ships. This file is
# excluded because the fixtures above are TODOs by design.
python3 .claude/kit/todo_sweep.py --exclude check.sh --check
