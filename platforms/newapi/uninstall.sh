#!/usr/bin/env bash
# 卸载 NEW API
set -euo pipefail

NEWAPI_DIR="$HOME/.newapi-termux"

echo "=== Uninstalling NEW API ==="

# Stop service
[ -x "$NEWAPI_DIR/bin/newapi-stop" ] && "$NEWAPI_DIR/bin/newapi-stop" 2>/dev/null || true

# Remove binaries
rm -rf "$NEWAPI_DIR/bin"

# Remove CLI command
rm -f "$PREFIX/bin/manage-newapi"

# Clean PATH from .bashrc
sed -i '/\.newapi-termux/d' "$HOME/.bashrc" 2>/dev/null || true

echo "Uninstall complete."
echo "Data preserved at: $NEWAPI_DIR/data/"
echo "Logs preserved at: $NEWAPI_DIR/logs/"
echo ""
echo "To completely remove all data: rm -rf $NEWAPI_DIR"
