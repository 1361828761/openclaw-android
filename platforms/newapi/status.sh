#!/usr/bin/env bash
set -euo pipefail

BIN_DIR="$HOME/.newapi-termux/bin"
[ -x "$BIN_DIR/newapi-status" ] && exec "$BIN_DIR/newapi-status"

echo "Error: newapi-status not found"
exit 1
