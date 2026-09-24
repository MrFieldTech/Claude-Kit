#!/usr/bin/env bash
# Claude-Kit: install, update, and report the kit in a repository.
#
#   bash <kit checkout>/.claude/kit/kit.sh install <repository>
#       Copy the kit-owned files from a checkout of the kit into a repository
#       and write .claude/kit/MANIFEST. Commits nothing.
#   bash .claude/kit/kit.sh status
#       Print the one line session-open reports as Kit:. Changes nothing.
#   bash .claude/kit/kit.sh update
#       Fetch the kit from the source MANIFEST records and install it over the
#       copy here. Commits nothing.
#
# Kit-owned files are everything under .claude/kit/ and the two skill
# directories. An install replaces them whole and touches nothing else.
# An install or update refuses to overwrite a kit-owned file edited in place
# unless given --discard-local-edits, because the edit may be the only copy
# of a fix that belongs in the kit.
#
# Needs bash, git, and sha256sum or shasum. Nothing else.

set -euo pipefail

KIT_DIRS=(".claude/kit" ".claude/skills/session-open" ".claude/skills/session-close")
MANIFEST=".claude/kit/MANIFEST"
TMP_DIR=""
trap '[ -z "$TMP_DIR" ] || rm -rf "$TMP_DIR"' EXIT

die() {
  printf 'kit.sh: %s\n' "$*" >&2
  exit 1
}

usage() {
  sed -n '2,11p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

sha() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | cut -d' ' -f1
  else
    shasum -a 256 "$1" | cut -d' ' -f1
  fi
}

# Every kit-owned file under a root, as paths relative to it, sorted, without
# the manifest and without anything Python caches.
kit_files() {
  local root="$1" dir
  for dir in "${KIT_DIRS[@]}"; do
    [ -d "$root/$dir" ] || continue
    (cd "$root" && find "$dir" -type f \
      ! -path "$MANIFEST" ! -name '*.pyc' ! -path '*/__pycache__/*')
  done | LC_ALL=C sort
}

# "<sha256>  <path>" for every kit-owned file under a root.
kit_sums() {
  local root="$1" file
  kit_files "$root" | while IFS= read -r file; do
    printf '%s  %s\n' "$(sha "$root/$file")" "$file"
  done
}

manifest_field() {
  sed -n "s/^$1: //p" "$2" | head -n 1
}

# "<sha256>  <path>" for every file the manifest lists.
manifest_sums() {
  sed -n 's/^  \([0-9a-f]\{64\}  .*\)$/\1/p' "$1"
}

# Kit-owned files whose content no longer matches the manifest, one per line,
# including files the manifest lists that are gone and files it does not list.
local_edits() {
  local root="$1" want path
  manifest_sums "$root/$MANIFEST" | while read -r want path; do
    if [ ! -f "$root/$path" ]; then
      printf '%s (deleted)\n' "$path"
    elif [ "$(sha "$root/$path")" != "$want" ]; then
      printf '%s\n' "$path"
    fi
  done
  kit_files "$root" | while IFS= read -r path; do
    manifest_sums "$root/$MANIFEST" | cut -c67- | grep -qxF "$path" \
      || printf '%s (added)\n' "$path"
  done
}

repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || die "not inside a git repository"
}

# Clone the source into a directory, quietly and without prompting.
fetch_source() {
  local source="$1" into="$2"
  case "$source" in
    /*) source="file://$source" ;;
  esac
  GIT_TERMINAL_PROMPT=0 git clone --quiet --depth 1 "$source" "$into" >/dev/null 2>&1
}

cmd_install() {
  local target="" discard=0 arg
  for arg in "$@"; do
    case "$arg" in
      --discard-local-edits) discard=1 ;;
      -*) die "unknown option: $arg" ;;
      *) [ -z "$target" ] || die "one repository at a time"; target="$arg" ;;
    esac
  done
  [ -n "$target" ] || die "usage: kit.sh install <repository>"

  local src
  src="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
  [ -f "$src/VERSION" ] || die "$src is not a checkout of the kit: it has no VERSION file"
  [ -d "$target" ] || die "no such directory: $target"
  target="$(cd "$target" && pwd)"
  git -C "$target" rev-parse --git-dir >/dev/null 2>&1 || die "$target is not a git repository"
  [ "$src" != "$target" ] || die "this is the kit's own repository, which runs on its source files"

  if [ -f "$target/$MANIFEST" ] && [ "$discard" -eq 0 ]; then
    local edits
    edits="$(local_edits "$target")"
    if [ -n "$edits" ]; then
      printf 'kit.sh: these kit-owned files were edited in place:\n%s\n' "$edits" >&2
      die "move the change into the kit first, or run again with --discard-local-edits"
    fi
  fi

  local version commit source
  version="$(tr -d '[:space:]' < "$src/VERSION")"
  commit="$(git -C "$src" rev-parse HEAD 2>/dev/null || echo unknown)"
  source="${KIT_SOURCE:-$(git -C "$src" config --get remote.origin.url 2>/dev/null || echo unknown)}"

  local path
  if [ ! -f "$target/$MANIFEST" ]; then
    kit_files "$target" | while IFS= read -r path; do
      printf 'kit.sh: replacing %s, which no kit install wrote\n' "$path" >&2
    done
  fi

  local dir
  for dir in "${KIT_DIRS[@]}"; do
    rm -rf "${target:?}/$dir"
  done
  kit_files "$src" | while IFS= read -r path; do
    mkdir -p "$target/$(dirname "$path")"
    cp "$src/$path" "$target/$path"
  done
  chmod +x "$target/.claude/kit/kit.sh"

  {
    printf '# Written by kit.sh install. Never edit by hand.\n'
    printf 'version: %s\n' "$version"
    printf 'source: %s\n' "$source"
    printf 'commit: %s\n' "$commit"
    printf 'files:\n'
    kit_sums "$target" | sed 's/^/  /'
  } > "$target/$MANIFEST"

  printf 'Installed Claude-Kit %s, commit %s, into %s\n' "$version" "${commit:0:7}" "$target"
}

cmd_status() {
  local root
  root="$(repo_root)"

  if [ ! -f "$root/$MANIFEST" ]; then
    if [ -f "$root/VERSION" ] && [ -f "$root/.claude/kit/kit.sh" ] && [ -f "$root/.claude/kit/HOUSE.md" ]; then
      printf '%s, the kit source itself\n' "$(tr -d '[:space:]' < "$root/VERSION")"
    else
      printf 'not installed\n'
    fi
    return 0
  fi

  local version source edits state
  version="$(manifest_field version "$root/$MANIFEST")"
  source="$(manifest_field source "$root/$MANIFEST")"
  edits="$(local_edits "$root" | paste -sd ',' - | sed 's/,/, /g')"

  TMP_DIR="$(mktemp -d)"
  if ! fetch_source "$source" "$TMP_DIR/kit" || [ ! -f "$TMP_DIR/kit/VERSION" ]; then
    state="source unreachable"
  else
    local latest
    latest="$(tr -d '[:space:]' < "$TMP_DIR/kit/VERSION")"
    if [ "$(kit_sums "$TMP_DIR/kit")" = "$(manifest_sums "$root/$MANIFEST")" ]; then
      state="current"
    elif [ "$latest" = "$version" ]; then
      state="differs from the source at the same version"
    elif [ "$(printf '%s\n%s\n' "$version" "$latest" | sort -V | tail -n 1)" = "$latest" ]; then
      state="$latest available"
    else
      state="ahead of the source, which is at $latest"
    fi
  fi

  if [ -n "$edits" ]; then
    printf '%s, %s, edited locally: %s\n' "$version" "$state" "$edits"
  else
    printf '%s, %s\n' "$version" "$state"
  fi
}

cmd_update() {
  local root discard=""
  root="$(repo_root)"
  case "${1:-}" in
    "") ;;
    --discard-local-edits) discard="$1" ;;
    *) die "unknown option: $1" ;;
  esac
  [ -f "$root/$MANIFEST" ] || die "no $MANIFEST here: install the kit first"

  local source
  source="$(manifest_field source "$root/$MANIFEST")"
  TMP_DIR="$(mktemp -d)"
  fetch_source "$source" "$TMP_DIR/kit" || die "cannot fetch the kit from $source"
  [ -f "$TMP_DIR/kit/.claude/kit/kit.sh" ] || die "$source holds no kit"
  KIT_SOURCE="$source" bash "$TMP_DIR/kit/.claude/kit/kit.sh" install "$root" $discard
}

case "${1:-}" in
  install) shift; cmd_install "$@" ;;
  status) shift; cmd_status "$@" ;;
  update) shift; cmd_update "$@" ;;
  -h|--help|help) usage 0 ;;
  *) usage 1 ;;
esac
