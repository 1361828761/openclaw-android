#!/usr/bin/env bash
# NEW API 更新脚本
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

NEWAPI_DIR="$HOME/.newapi-termux"
BIN_DIR="$NEWAPI_DIR/bin"
NEWAPI_BIN="$BIN_DIR/newapi"

echo "=== 更新 NEW API ==="

# 检测颜色
GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

# 获取最新版本
LATEST=$(curl -s "https://api.github.com/repos/QuantumNous/new-api/releases/latest" 2>/dev/null | grep '"tag_name":' | sed 's/.*"tag_name": "\([^"]*\)".*/\1/')
[ -z "$LATEST" ] && { echo "无法获取版本信息"; exit 1; }

if [ -f "$NEWAPI_BIN" ]; then
  CURRENT=$("$BIN_DIR/newapi-run" --version 2>/dev/null | head -1 || echo "unknown")
else
  CURRENT="未安装"
fi

echo "当前版本: $CURRENT"
echo "最新版本: $LATEST"

if [ "$CURRENT" = "$LATEST" ]; then
  echo "已经是最新版本"
  exit 0
fi

read -rp "是否更新? [Y/n] " c
[[ "${c:-y}" =~ ^[Nn]$ ]] && exit 0

# 记录当前端口
CURRENT_PORT="3000"
if [ -f "$NEWAPI_DIR/newapi.pid" ]; then
  CURRENT_PORT=$(netstat -tlnp 2>/dev/null | grep "$(cat "$NEWAPI_DIR"/newapi.pid)" 2>/dev/null | grep -o ':[0-9]*' | head -1 | tr -d ':' || echo "3000")
fi

# 停止服务
"$BIN_DIR/newapi-stop" 2>/dev/null || true

# 备份
if [ -f "$HOME/one-api.db" ]; then
  mkdir -p "$NEWAPI_DIR/backup"
  cp "$HOME/one-api.db" "$NEWAPI_DIR/backup/one-api-$(date +%Y%m%d_%H%M%S).db"
  echo "数据库已备份"
fi

# 下载新版本
echo "正在下载 $LATEST..."
URL="https://github.com/QuantumNous/new-api/releases/download/${LATEST}/new-api-arm64-${LATEST}"

if ! curl -fL --max-time 300 -o "$NEWAPI_BIN.tmp" "$URL" 2>/dev/null; then
  echo "主 URL 失败，尝试镜像..."
  if ! curl -fL --max-time 300 -o "$NEWAPI_BIN.tmp" "https://ghfast.top/$URL" 2>/dev/null; then
    echo -e "${RED}[失败]${NC} 下载失败"
    exit 1
  fi
fi

# 替换二进制文件
[ -f "$NEWAPI_BIN" ] && mv "$NEWAPI_BIN" "$NEWAPI_BIN.bak"
mv "$NEWAPI_BIN.tmp" "$NEWAPI_BIN"
chmod +x "$NEWAPI_BIN"

# 启动服务
echo -e "${GREEN}[OK]${NC} 更新完成"
"$BIN_DIR/newapi-start" "$CURRENT_PORT"
