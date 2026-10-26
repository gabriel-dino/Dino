#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
if command -v love >/dev/null 2>&1; then
    exec love . "$@"
elif [[ -x .runtime/root/usr/bin/love-11.5 ]]; then
    export LD_LIBRARY_PATH="$PWD/.runtime/root/usr/lib/x86_64-linux-gnu${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    exec .runtime/root/usr/bin/love-11.5 . "$@"
else
    echo 'LÖVE lipsește. Instalează-l cu: sudo apt install love lua5.4' >&2
    exit 1
fi
