#!/usr/bin/env bash
set -euo pipefail
project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if command -v lua >/dev/null 2>&1; then
    exec lua "$@"
else
    exec "$project_dir/.runtime/root/usr/bin/lua5.4" "$@"
fi
