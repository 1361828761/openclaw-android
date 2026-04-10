#!/usr/bin/env bash
set -euo pipefail

BIN_DIR="$HOME/.newapi-termux/bin"
[ -x "$BIN_DIR/newapi-stop" ] && exec "$BIN_DIR/newapi-stop"

echo "Error: newapi-stop not found"
exit 1
