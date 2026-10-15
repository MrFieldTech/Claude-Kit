#!/usr/bin/env bash
# Checks the kit before it merges. Run from anywhere: bash check.sh
#
# 1. No kit-owned file holds an address, and neither one nor a session
#    reference holds a name on the private list of project terms when one is
#    given.
# 2. No file in the repository holds an em dash.
# 3. The scripts parse, each skill's frontmatter is whole, every practice
#    is pointed at and every pointer names a practice that exists, and every
#    kit-owned directory keeps LF line endings.
# 4. VERSION is a version number, CHANGELOG.md has an entry for it, and the
#    README's update block names it.
# 5. An install into a scratch repository works end to end: the manifest,
#    the status line, the guard against overwriting local edits, and the
#    TODO sweep.
# 6. The secrets tool stores, places, locks, checks, shows, rekeys and
#    decrypts values with age, and prints the steps for keys. Skipped when
#    age is not installed, except in CI. The Node decrypter is tested when
#    node is installed, fully when CHECK_NODE_MODULES names a node_modules
#    directory holding the age-encryption package.
# 7. This repository's own TODO.md is current.
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
# This repository's own session references are public too, so they are
# held to the same list. CLAUDE.md has the close redact a match before the
# reference is committed.
TERMS_SCANNED=("${KIT_OWNED[@]}")
[ -d .claude/references ] && TERMS_SCANNED+=(.claude/references)
if [ -n "$terms" ]; then
  status=0
  grep -rnIE "$terms" "${TERMS_SCANNED[@]}" || status=$?
  [ "$status" -ne 0 ] && [ "$status" -ne 1 ] && fail "the private terms are not a valid pattern"
  [ "$status" -eq 0 ] && fail "the lines above name something that belongs to one project"
  echo "check: kit-owned files hold no address, and they and the references name no project"
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
for script in todo_sweep.py secrets.py; do
  python3 -c 'import ast, sys; ast.parse(open(sys.argv[1]).read())' ".claude/kit/$script"
done
if command -v node >/dev/null 2>&1; then
  node --check .claude/kit/secrets-decrypt.mjs
fi
for skill in session-open session-close; do
  file=".claude/skills/$skill/SKILL.md"
  [ "$(sed -n 1p "$file")" = "---" ] || fail "$file does not open with frontmatter"
  grep -qx "name: $skill" "$file" || fail "$file does not name itself $skill"
  grep -qx "disable-model-invocation: true" "$file" || fail "$file can be invoked by the model"
  grep -q '^description: ' "$file" || fail "$file has no description"
done
# A practice is read only when a pointer names it, so a practice no pointer
# names is never read, and a pointer to a missing file sends a session
# nowhere. HOUSE.md's Practices section is where every practice is named.
practices_section="$(sed -n '/^## Practices$/,/^## /p' .claude/kit/HOUSE.md)"
[ -n "$practices_section" ] || fail "HOUSE.md has no Practices section"
for file in .claude/kit/practices/*.md; do
  grep -qF "\`$(basename "$file")\`" <<< "$practices_section" \
    || fail "HOUSE.md's Practices section does not name $file"
done
for name in $(grep -oE '`[a-z-]+\.md`' <<< "$practices_section" | tr -d '`' | sort -u); do
  [ -f ".claude/kit/practices/$name" ] || fail "HOUSE.md names the practice $name, which does not exist"
done
for path in $(grep -rhoE '\.claude/kit/practices/[a-z-]+\.md' "${KIT_OWNED[@]}" | sort -u); do
  [ -f "$path" ] || fail "a kit-owned file points at $path, which does not exist"
done
for dir in "${KIT_OWNED[@]}"; do
  grep -qx '\* text eol=lf' "$dir/.gitattributes" 2>/dev/null \
    || fail "$dir has no .gitattributes keeping LF line endings"
done
if grep -rlI $'\r' "${KIT_OWNED[@]}"; then
  fail "the files above hold a carriage return"
fi
echo "check: scripts parse, skills are whole, practices are pointed at, and line endings stay LF"

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
mkdir -p "$repo/.claude/references"
printf 'TODO: never read either?\n' > "$repo/.claude/references/261015000000-check.md"
git -C "$repo" add notes.md code.py key.secrets.md .claude/references
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

# 6. The secrets tool, in a scratch repository of its own, with keys made
# outside it as the owner would make them. Values are fixed strings, so a
# grep for one proves it never reached a file in plaintext.
if command -v age >/dev/null 2>&1 && command -v age-keygen >/dev/null 2>&1; then
  srepo="$scratch/srepo"
  keys="$scratch/keys"
  mkdir -p "$keys"
  git init --quiet "$srepo"
  cp -R "$repo/.claude" "$srepo/"
  cp "$scratch/kit/.claude/kit/templates/HANDOFF.md" "$srepo/HANDOFF.md"
  # The template has no Credentials In Transit since 1.6.0. An older
  # HANDOFF.md keeps one, and the tool still reads it there.
  printf '\n## Credentials In Transit\n\nNone.\n' >> "$srepo/HANDOFF.md"
  for k in one two three; do age-keygen -o "$keys/$k" 2>/dev/null; done
  pub() { age-keygen -y "$keys/$1"; }
  secrets() { (cd "$srepo" && python3 .claude/kit/secrets.py "$@"); }

  (cd "$srepo" && python3 .claude/kit/secrets.py check >/dev/null) \
    || fail "secrets check fails on a repository with no secrets"
  if printf 'v' | secrets set secrets/svc.secrets.md "Token" >/dev/null 2>&1; then
    fail "secrets set encrypted with no secrets-recipients.txt"
  fi
  printf '# Owner\n%s\n# Recovery\n%s\n' "$(pub one)" "$(pub two)" > "$srepo/secrets-recipients.txt"

  secrets set secrets/svc.secrets.md "Token" >/dev/null <<< 'check-value-one'
  printf 'check-line-a\ncheck-line-b' | secrets set secrets/svc.secrets.md "Private key" >/dev/null
  secrets set secrets/svc.secrets.md "Token" >/dev/null <<< 'check-value-two'
  secrets set HANDOFF.md "Pending token" >/dev/null <<< 'check-value-transit'
  age -a -r "$(pub one)" -r "$(pub two)" > "$scratch/block" <<< 'check-value-placed'
  secrets place secrets/svc.secrets.md "Placed" < "$scratch/block" >/dev/null
  age -a -r "$(pub one)" > "$scratch/block" <<< 'x'
  if secrets place secrets/svc.secrets.md "Short" < "$scratch/block" >/dev/null 2>&1; then
    fail "secrets place took a block encrypted to fewer keys than secrets-recipients.txt lists"
  fi
  if printf 'v' | secrets set notes.md "Token" >/dev/null 2>&1; then
    fail "secrets set wrote to a file that is not a .secrets.md file"
  fi
  if grep -rq 'check-value\|check-line' "$srepo/secrets" "$srepo/HANDOFF.md"; then
    fail "a value reached a file in plaintext"
  fi
  secrets check >/dev/null || fail "secrets check fails on values set and placed by the tool"

  shown="$(secrets show secrets/svc.secrets.md --identity "$keys/two")"
  for want in '`check-value-two`' 'check-line-a' 'check-line-b' '`check-value-placed`'; do
    grep -qF -- "$want" <<< "$shown" || fail "secrets show did not give back $want"
  done
  grep -q 'check-value-one' <<< "$shown" && fail "secrets set kept a replaced value"
  [ "$(grep -c '^\*\*Token\*\*$' "$srepo/secrets/svc.secrets.md")" = 1 ] \
    || fail "secrets set added a second Token label instead of replacing its value"
  grep -qF '`check-value-transit`' <<< "$(SECRETS_AGE_KEY="$(cat "$keys/one")" secrets show HANDOFF.md)" \
    || fail "secrets show did not read a value in transit with SECRETS_AGE_KEY"

  printf -- '---\nslug: old\nupdated: 2026-01-01\n---\n\n**Password**\n\n`check-plain`\n\n**Codes**\n\n```\ncheck-code-1\ncheck-code-2\n```\n' \
    > "$srepo/old.secrets.md"
  if secrets check >/dev/null 2>&1; then fail "secrets check passed a file holding plaintext"; fi
  secrets lock old.secrets.md >/dev/null
  grep -q 'check-plain\|check-code' "$srepo/old.secrets.md" && fail "secrets lock left plaintext behind"
  secrets check >/dev/null || fail "secrets check fails after lock"
  grep -qF 'check-code-2' <<< "$(secrets show old.secrets.md --identity "$keys/one")" \
    || fail "secrets lock lost a value of more than one line"

  cp "$srepo/HANDOFF.md" "$scratch/handoff"
  sed -i.bak 's/^\*\*Pending token\*\*$/&\n\n`check-leak`/' "$srepo/HANDOFF.md"
  if secrets check >/dev/null 2>&1; then fail "secrets check passed plaintext under Credentials In Transit"; fi
  cp "$scratch/handoff" "$srepo/HANDOFF.md"
  printf -- '---\nslug: other\nupdated: 2026-01-01\n---\n' > "$srepo/wrong.secrets.md"
  if secrets check >/dev/null 2>&1; then fail "secrets check passed a file whose slug is not its name"; fi
  rm "$srepo/wrong.secrets.md" "$srepo/HANDOFF.md.bak"

  printf '%s\n' "$(pub three)" > "$srepo/secrets-recipients.txt"
  secrets rekey --identity "$keys/one" >/dev/null
  grep -qF '`check-value-transit`' <<< "$(secrets show HANDOFF.md --identity "$keys/three")" \
    || fail "secrets rekey did not re-encrypt HANDOFF.md to the new key"
  grep -qF 'check-code-1' <<< "$(secrets show old.secrets.md --identity "$keys/three")" \
    || fail "secrets rekey did not re-encrypt to the new key"
  if secrets show secrets/svc.secrets.md --identity "$keys/one" >/dev/null 2>&1; then
    fail "a removed key still reads a value after rekey"
  fi
  grep -qF "$(pub three)" <<< "$(secrets steps)" || fail "secrets steps does not write the keys in"

  # A session reference's companion is a secrets file like any other, and
  # no build decrypts it.
  companion=".claude/references/261015000000-check.secrets.md"
  secrets set "$companion" "Token" >/dev/null <<< 'check-value-companion'
  grep -qx 'slug: 261015000000-check' "$srepo/$companion" || fail "a companion's slug is not its name"
  secrets check >/dev/null || fail "secrets check fails on a companion"

  # Decrypt for a build: a copy at the same path under a gitignored
  # directory, the check build's placeholders, and every refusal.
  printf '/build-secrets/\n' > "$srepo/.gitignore"
  if secrets decrypt --out "$srepo/build-secrets" >/dev/null 2>&1; then
    fail "secrets decrypt ran with no key"
  fi
  if SECRETS_AGE_KEY="$(cat "$keys/three")" secrets decrypt --out "$srepo/tracked" >/dev/null 2>&1; then
    fail "secrets decrypt wrote into a directory git does not ignore"
  fi
  if SECRETS_AGE_KEY="$(cat "$keys/one")" secrets decrypt --out "$srepo/build-secrets" >"$scratch/out" 2>&1; then
    fail "secrets decrypt passed with a key that reads no value"
  fi
  grep -qF 'old.secrets.md: Password will not decrypt' "$scratch/out" \
    || fail "secrets decrypt did not name the file and label that would not decrypt: $(cat "$scratch/out")"
  [ -e "$srepo/build-secrets" ] && fail "secrets decrypt wrote files before every value decrypted"
  SECRETS_AGE_KEY="$(cat "$keys/three")" secrets decrypt --out "$srepo/build-secrets" >/dev/null \
    || fail "secrets decrypt failed with a key that reads every value"
  copy="$srepo/build-secrets/secrets/svc.secrets.md"
  for want in '`check-value-two`' 'check-line-a' '`check-value-placed`' '**Token**' 'slug: svc'; do
    grep -qF -- "$want" "$copy" || fail "secrets decrypt did not write $want"
  done
  grep -q 'BEGIN AGE' "$copy" && fail "secrets decrypt left an encrypted block in its copy"
  grep -qF 'check-code-1' "$srepo/build-secrets/old.secrets.md" || fail "secrets decrypt missed a file"
  [ -e "$srepo/build-secrets/HANDOFF.md" ] && fail "secrets decrypt wrote HANDOFF.md"
  [ -e "$srepo/build-secrets/.claude" ] && fail "secrets decrypt wrote a session reference's companion"
  [ "$(cd "$srepo" && git status --porcelain --untracked-files=all | grep -c build-secrets)" = 0 ] \
    || fail "the decrypted copy is not ignored by git"
  rm -rf "$srepo/build-secrets"
  mkdir "$scratch/noage"
  ln -s "$(command -v python3)" "$(command -v git)" "$scratch/noage/"
  SECRETS_CHECK_BUILD=1 PATH="$scratch/noage" \
    secrets decrypt --out "$srepo/build-secrets" >/dev/null \
    || fail "a check build needed a key or the age tool"
  grep -q 'check-value' "$copy" && fail "a check build wrote a real value"
  grep -qF '`secrets-check-build-placeholder`' "$copy" || fail "a check build wrote no placeholder"

  keys_out="$(secrets keys)"
  for want in age-key-owner.txt age-key-build.txt age-key-recovery.txt SECRETS_AGE_KEY; do
    grep -qF "$want" <<< "$keys_out" || fail "secrets keys does not mention $want"
  done
  grep -qF age-key-ops.txt <<< "$(secrets keys owner ops)" || fail "secrets keys ignored the holders named"
  grep -q age-key-build <<< "$(secrets keys owner ops)" && fail "secrets keys added a holder not named"

  # The Node decrypter must write what secrets.py writes.
  if command -v node >/dev/null 2>&1; then
    rm -rf "$srepo/build-secrets"
    (cd "$srepo" && SECRETS_CHECK_BUILD=1 node .claude/kit/secrets-decrypt.mjs --out build-secrets >/dev/null) \
      || fail "the Node decrypter failed a check build"
    grep -qF '`secrets-check-build-placeholder`' "$copy" || fail "the Node check build wrote no placeholder"
    [ -e "$srepo/build-secrets/.claude" ] && fail "the Node decrypter wrote a session reference's companion"
    if (cd "$srepo" && node .claude/kit/secrets-decrypt.mjs --out build-secrets >/dev/null 2>&1); then
      fail "the Node decrypter ran with no key"
    fi
    if (cd "$srepo" && SECRETS_CHECK_BUILD=1 node .claude/kit/secrets-decrypt.mjs --out tracked >/dev/null 2>&1); then
      fail "the Node decrypter wrote into a directory git does not ignore"
    fi
    if [ -n "${CHECK_NODE_MODULES:-}" ]; then
      ln -s "$CHECK_NODE_MODULES" "$srepo/node_modules"
      printf 'node_modules\n' >> "$srepo/.gitignore"
      SECRETS_AGE_KEY="$(cat "$keys/three")" secrets decrypt --out "$scratch/py-out" >/dev/null
      rm -rf "$srepo/build-secrets"
      (cd "$srepo" && SECRETS_AGE_KEY="$(cat "$keys/three")" node .claude/kit/secrets-decrypt.mjs --out build-secrets >/dev/null) \
        || fail "the Node decrypter failed with a key that reads every value"
      diff -r "$scratch/py-out" "$srepo/build-secrets" >&2 \
        || fail "the Node decrypter wrote something other than secrets.py decrypt, diff above"
      if (cd "$srepo" && SECRETS_AGE_KEY="$(cat "$keys/one")" node .claude/kit/secrets-decrypt.mjs --out build-secrets >/dev/null 2>&1); then
        fail "the Node decrypter passed with a key that reads no value"
      fi
    fi
  fi
  echo "check: the secrets tool works"
elif [ -n "${CI:-}" ]; then
  fail "age is not installed, and CI must test the secrets tool"
else
  echo "check: the secrets tool was not tested (age is not installed)"
fi

# 7. This repository keeps its own TODO.md by the sweep it ships. This file is
# excluded because the fixtures above are TODOs by design.
python3 .claude/kit/todo_sweep.py --exclude check.sh --check
