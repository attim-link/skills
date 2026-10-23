#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: update.sh <slug> <file-or-dir> [attim update options]

Examples:
  ./scripts/update.sh my-site ./dist
  ./scripts/update.sh my-site ./dist --claim-token ANONYMOUS_CLAIM_TOKEN
  ./scripts/update.sh my-site ./dist --dry-run
  ./scripts/update.sh my-site ./dist --no-finalize

This helper delegates to the official ATTIM CLI. It uses an installed `attim`
binary when available, otherwise it runs `npx -y attim`.
USAGE
}

if [[ $# -lt 2 || "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  if [[ $# -lt 2 ]]; then
    exit 1
  fi
  exit 0
fi

if command -v attim >/dev/null 2>&1; then
  exec attim update "$@"
fi

command -v npx >/dev/null 2>&1 || {
  echo "error: requires either an installed 'attim' binary or npx" >&2
  exit 1
}

exec npx -y attim update "$@"
