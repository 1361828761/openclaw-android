#!/usr/bin/env bash
# OpenClaw 更新脚本
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$HOME/.openclaw-android/scripts/lib.sh" ]; then
  source "$HOME/.openclaw-android/scripts/lib.sh"
else
  source "$SCRIPT_DIR/scripts/lib.sh"
fi

echo "=== 更新 OpenClaw ==="

# 运行平台更新
if [ -f "$SCRIPT_DIR/platforms/openclaw/update.sh" ]; then
  bash "$SCRIPT_DIR/platforms/openclaw/update.sh"
elif [ -f "$HOME/.openclaw-android/platforms/openclaw/update.sh" ]; then
  bash "$HOME/.openclaw-android/platforms/openclaw/update.sh"
else
  # 备用: 通过 npm 更新
  npm update -g openclaw || npm install -g openclaw@latest
fi

echo -e "${GREEN}[OK]${NC} OpenClaw 更新完成"
