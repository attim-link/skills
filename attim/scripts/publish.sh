#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: publish.sh <file-or-dir> [attim publish options]

Examples:
  ./scripts/publish.sh ./dist
  ./scripts/publish.sh index.html
  ./scripts/publish.sh ./dist --slug my-site
  ./scripts/publish.sh ./dist --password "secret-password" --password-access-ttl 86400

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
  exec attim publish "$@"
fi

command -v npx >/dev/null 2>&1 || {
  echo "error: requires either an installed 'attim' binary or npx" >&2
  exit 1
}

exec npx -y attim publish "$@"
