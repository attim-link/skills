#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: claim.sh <slug> [attim claim options]

Examples:
  ./scripts/claim.sh my-site
  ./scripts/claim.sh my-site --workspace 1
  ./scripts/claim.sh --all

This helper delegates to the official ATTIM CLI. It uses an installed `attim`
binary when available, otherwise it runs `npx -y attim`.
USAGE
}

if [[ $# -eq 0 || "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  if [[ $# -eq 0 ]]; then
    exit 1
  fi
  exit 0
fi

if command -v attim >/dev/null 2>&1; then
  exec attim claim "$@"
fi

command -v npx >/dev/null 2>&1 || {
  echo "error: requires either an installed 'attim' binary or npx" >&2
  exit 1
}

exec npx -y attim claim "$@"
