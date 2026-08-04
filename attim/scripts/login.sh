#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: login.sh [attim login options]

Examples:
  ./scripts/login.sh
  ./scripts/login.sh --rotate
  ./scripts/login.sh --token attim_uat_...

This helper delegates to the official ATTIM CLI. It uses an installed `attim`
binary when available, otherwise it runs `npx -y attim`.
USAGE
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

if command -v attim >/dev/null 2>&1; then
  exec attim login "$@"
fi

command -v npx >/dev/null 2>&1 || {
  echo "error: requires either an installed 'attim' binary or npx" >&2
  exit 1
}

exec npx -y attim login "$@"
