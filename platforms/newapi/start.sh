#!/usr/bin/env bash
set -euo pipefail

BIN_DIR="$HOME/.newapi-termux/bin"
[ -x "$BIN_DIR/newapi-start" ] && exec "$BIN_DIR/newapi-start" "$@"

echo "Error: newapi-start not found"
exit 1
