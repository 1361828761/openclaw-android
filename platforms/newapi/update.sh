#!/usr/bin/env bash
# 更新 NEW API
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/../scripts/lib.sh"

NEWAPI_DIR="$HOME/.newapi-termux"
BIN_DIR="$NEWAPI_DIR/bin"
NEWAPI_BIN="$BIN_DIR/newapi"

echo "=== Updating NEW API ==="
LATEST=$(curl -s "https://api.github.com/repos/QuantumNous/new-api/releases/latest" 2>/dev/null | grep '"tag_name":' | sed 's/.*"tag_name": "\([^"]*\)".*/\1/')
[ -z "$LATEST" ] && { echo "Could not get version"; exit 1; }

if [ -f "$NEWAPI_BIN" ]; then
  CURRENT=$("$BIN_DIR/newapi-run" --version 2>/dev/null | head -1 || echo "unknown")
else
  CURRENT="not installed"
fi

echo "Current: $CURRENT"
echo "Latest: $LATEST"
[ "$CURRENT" = "$LATEST" ] && { echo "Already up to date"; exit 0; }

read -rp "Update? [Y/n] " c
[[ "${c:-y}" =~ ^[Nn]$ ]] && exit 0

# Record current port
CURRENT_PORT="3000"
if [ -f "$NEWAPI_DIR/newapi.pid" ]; then
  CURRENT_PORT=$(netstat -tlnp 2>/dev/null | grep "$(cat "$NEWAPI_DIR"/newapi.pid)" | grep -o ':[0-9]*' | head -1 | tr -d ':' || echo "3000")
fi

# Stop service
"$BIN_DIR/newapi-stop" 2>/dev/null || true

# Backup
if [ -f "$HOME/one-api.db" ]; then
  mkdir -p "$NEWAPI_DIR/backup"
  BACKUP_FILE="$NEWAPI_DIR/backup/newapi-$(date +%Y%m%d_%H%M%S).db"
  cp "$HOME/one-api.db" "$BACKUP_FILE" && echo "Backup: $BACKUP_FILE"
fi

# Download new version
echo "Downloading $LATEST..."
URL="https://github.com/QuantumNous/new-api/releases/download/${LATEST}/new-api-arm64-${LATEST}"
if ! curl -fL --max-time 300 -o "$NEWAPI_BIN.tmp" "$URL" 2>/dev/null; then
  curl -fL --max-time 300 -o "$NEWAPI_BIN.tmp" "https://ghfast.top/$URL" || {
    echo -e "${RED}[FAIL]${NC} Download failed"
    exit 1
  }
fi

[ -f "$NEWAPI_BIN" ] && mv "$NEWAPI_BIN" "$NEWAPI_BIN.bak"
mv "$NEWAPI_BIN.tmp" "$NEWAPI_BIN"
chmod +x "$NEWAPI_BIN"

# Start service
echo -e "${GREEN}[OK]${NC} Update complete"
"$BIN_DIR/newapi-start" "$CURRENT_PORT"
