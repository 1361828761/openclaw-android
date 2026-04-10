#!/usr/bin/env bash
# OpenClaw 卸载脚本
set -euo pipefail

echo "=== 卸载 OpenClaw ==="

PROJECT_DIR="$HOME/.openclaw-android"

# 运行平台卸载程序（如果存在）
if [ -f "$PROJECT_DIR/platforms/openclaw/uninstall.sh" ]; then
  bash "$PROJECT_DIR/platforms/openclaw/uninstall.sh"
fi

# 移除 npm 包
npm uninstall -g openclaw 2>/dev/null || true
npm uninstall -g clawdhub 2>/dev/null || true

# 移除项目目录
rm -rf "$PROJECT_DIR"

# 移除命令
rm -f "$PREFIX/bin/oa"
rm -f "$PREFIX/bin/oaupdate"
rm -f "$PREFIX/bin/manage-openclaw"
rm -f "$PREFIX/bin/update-openclaw"

# 清理 .bashrc 中的环境配置
sed -i '/OpenClaw on Android/d' "$HOME/.bashrc" 2>/dev/null || true

echo "OpenClaw 已卸载。"
echo "数据保留在: $HOME/.openclaw/"
echo "如需删除数据: rm -rf $HOME/.openclaw"
