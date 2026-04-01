#!/usr/bin/env bash
# export_git_revisions_from_repo.sh
# Export each committed revision of a given file from a specified repo into an output directory.
# Usage:
#   ./export_git_revisions_from_repo.sh [--repo /path/to/repo] <path/to/file> <output_dir>
#
# Examples:
#   # run from inside repo (default)
#   ./export_git_revisions_from_repo.sh src/foo.txt /tmp/revs
#   # run from repo A but export file from repo B
#   ./export_git_revisions_from_repo.sh --repo /path/to/repoB /path/to/repoB/src/foo.txt /tmp/revs

set -euo pipefail
IFS=$'\n\t'

die()  { printf '%s\n' "ERROR: $*" >&2; exit 1; }
info() { printf '%s\n' "$*"; }

# --- parse args ---
repo="."
if [ "$#" -lt 2 ]; then
  cat <<USAGE
Usage: $0 [--repo /path/to/repo] <path/to/file> <output_dir>

If --repo is omitted, the current working directory is used as the git repo.
File path may be absolute or relative. If absolute and inside the repo, it will be converted to a repo-relative path.
USAGE
  exit 2
fi

if [ "$1" = "--repo" ]; then
  if [ "$#" -lt 3 ]; then
    die "Missing arguments after --repo"
  fi
  repo="$2"
  shift 2
fi

file_path="$1"
out_dir="$2"
basename="$(basename -- "$file_path")"

# --- repo checks ---
# Ensure repo exists and is a git repo
if ! git -C "$repo" rev-parse --git-dir >/dev/null 2>&1; then
  die "Repository path '$repo' is not a git repository (or does not exist)."
fi

# Resolve repository top-level absolute path
repo_root="$(git -C "$repo" rev-parse --show-toplevel 2>/dev/null)" || \
  die "Unable to determine repository top-level for '$repo'."

# If user passed an absolute path inside the repo, convert to repo-relative path.
# If file_path is absolute and starts with repo_root/, strip the prefix.
if [ "${file_path#/}" != "$file_path" ]; then
  # file_path is absolute
  case "$file_path" in
    "$repo_root"/*) rel_path="${file_path#$repo_root/}" ;;
    "$repo_root")    rel_path="$(basename "$file_path")" ;;   # root file edge-case
    *)               # absolute but not inside repo; user might have passed a path outside repo
                     # assume they meant a repo-relative path; try to use basename fallback
                     rel_path="$file_path"
                     ;;
  esac
else
  # file_path is relative — interpret it relative to the repo root
  rel_path="$file_path"
fi

# Verify file has at least one commit in the target repo (follow renames)
if ! git -C "$repo" log --follow -1 --pretty=format:%H -- "$rel_path" >/dev/null 2>&1; then
  die "File '$file_path' (interpreted as '$rel_path' in repo '$repo_root') is not tracked or has no commits in that repo."
fi

# Ensure output directory exists
mkdir -p -- "$out_dir"

# --- export loop: use git -C "$repo" for all git calls ---
git -C "$repo" log --follow --pretty=format:%H'|'%cI -- "$rel_path" |
while IFS='|' read -r sha ciso; do
  # Normalize ciso (ISO8601) to YYYYMMDD-HHMMSS
  iso="${ciso%+*}"
  iso="${iso%Z}"
  date_part="${iso%%T*}"
  time_part="${iso#*T}"
  time_part="${time_part%%.*}"
  time_part="${time_part//:/}"
  timestamp="${date_part//-}-${time_part}"

  target="${out_dir%/}/${timestamp}-${basename}"

  if [ -e "$target" ]; then
    short="${sha:0:8}"
    target="${out_dir%/}/${timestamp}-${short}-${basename}"
  fi

  # Export blob from target repo/commit.
  if git -C "$repo" show "${sha}:${rel_path}" >"$target" 2>/dev/null; then
    info "Wrote: $target"
  else
    # cleanup and message
    [ -s "$target" ] || rm -f -- "$target"
    info "Skipped commit ${sha}: file not present as '${rel_path}' in repo '$repo'"
  fi
done

info "Done — exported revisions to: $out_dir"
