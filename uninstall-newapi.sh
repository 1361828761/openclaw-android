#!/usr/bin/env bash
# NEW API 卸载脚本
set -euo pipefail

echo "=== 卸载 NEW API ==="

PROJECT_DIR="$HOME/.newapi-termux"

# 运行平台卸载程序（如果存在）
if [ -f "$PROJECT_DIR/platforms/newapi/uninstall.sh" ]; then
  bash "$PROJECT_DIR/platforms/newapi/uninstall.sh"
fi

# 停止服务
[ -x "$PROJECT_DIR/bin/newapi-stop" ] && "$PROJECT_DIR/bin/newapi-stop" 2>/dev/null || true

# 移除二进制文件
rm -rf "$PROJECT_DIR/bin"

# 移除命令
rm -f "$PREFIX/bin/manage-newapi"
rm -f "$PREFIX/bin/update-newapi"

# 从 .bashrc 中清理 PATH
sed -i '/\.newapi-termux/d' "$HOME/.bashrc" 2>/dev/null || true

echo "NEW API 已卸载。"
echo "数据保留在: $PROJECT_DIR/data/"
echo "日志保留在: $PROJECT_DIR/logs/"
echo ""
echo "如需完全删除所有数据:"
echo "  rm -rf $PROJECT_DIR"
