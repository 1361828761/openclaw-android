#!/usr/bin/env bash
# 统一卸载脚本 - OpenClaw 和 NEW API
set -euo pipefail

PROJECT_DIR="$HOME/.openclaw-android"
NEWAPI_DIR="$HOME/.newapi-termux"

if [ -f "$HOME/.openclaw-android/scripts/lib.sh" ]; then
  source "$HOME/.openclaw-android/scripts/lib.sh"
else
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BOLD='\033[1m'
  NC='\033[0m'
  PLATFORM_MARKER="$PROJECT_DIR/.platform"
  BASHRC_MARKER_START="# >>> OpenClaw on Android >>>"
  BASHRC_MARKER_END="# <<< OpenClaw on Android <<<"

  ask_yn() {
    local prompt="$1"
    local reply
    read -rp "$prompt [Y/n] " reply < /dev/tty
    [[ "${reply:-}" =~ ^[Nn]$ ]] && return 1
    return 0
  }
fi

echo ""
echo -e "${BOLD}========================================${NC}"
echo -e "${BOLD}  统一平台卸载器${NC}"
echo -e "${BOLD}========================================${NC}"
echo ""

reply=""
read -rp "这将移除安装。是否继续? [y/N] " reply < /dev/tty
if [[ ! "$reply" =~ ^[Yy]$ ]]; then
  echo "已取消。"
  exit 0
fi

step() {
  echo ""
  echo -e "${BOLD}[$1] $2${NC}"
  echo "----------------------------------------"
}

# 步骤 1: 平台卸载
step "1" "平台卸载"

# 从标记文件检查已安装的平台
INSTALLED_PLATFORMS=()
if [ -f "$PLATFORM_MARKER" ]; then
  while IFS= read -r line; do
    INSTALLED_PLATFORMS+=("$line")
  done < "$PLATFORM_MARKER"
fi

# 卸载每个检测到的平台
for platform in "${INSTALLED_PLATFORMS[@]}"; do
  case "$platform" in
    openclaw)
      echo "正在卸载 OpenClaw..."
      PLATFORM_UNINSTALL="$PROJECT_DIR/platforms/openclaw/uninstall.sh"
      if [ -f "$PLATFORM_UNINSTALL" ]; then
        bash "$PLATFORM_UNINSTALL"
      fi
      ;;
    newapi)
      echo "正在卸载 NEW API..."
      NEWAPI_UNINSTALL="$NEWAPI_DIR/platforms/newapi/uninstall.sh"
      if [ -f "$NEWAPI_UNINSTALL" ]; then
        bash "$NEWAPI_UNINSTALL"
      else
        # 直接卸载
        [ -x "$NEWAPI_DIR/bin/newapi-stop" ] && "$NEWAPI_DIR/bin/newapi-stop" 2>/dev/null || true
      fi
      ;;
  esac
done

# 步骤 2: code-server
step "2" "code-server"
if pgrep -f "code-server" &>/dev/null; then
  pkill -f "code-server" || true
  echo -e "${GREEN}[OK]${NC} 已停止 code-server"
fi

if ls "$HOME/.local/lib"/code-server-* &>/dev/null 2>&1; then
  rm -rf "$HOME/.local/lib"/code-server-*
  echo -e "${GREEN}[OK]${NC} 已移除 code-server"
else
  echo -e "${YELLOW}[跳过]${NC} 未找到 code-server"
fi

if [ -f "$HOME/.local/bin/code-server" ] || [ -L "$HOME/.local/bin/code-server" ]; then
  rm -f "$HOME/.local/bin/code-server"
  echo -e "${GREEN}[OK]${NC} 已移除 ~/.local/bin/code-server"
fi

rmdir "$HOME/.local/bin" 2>/dev/null || true
rmdir "$HOME/.local/lib" 2>/dev/null || true
rmdir "$HOME/.local" 2>/dev/null || true

# 步骤 3: Chromium
step "3" "Chromium"
if command -v chromium-browser &>/dev/null || command -v chromium &>/dev/null; then
  if ask_yn "是否移除 Chromium 浏览器?"; then
    pkg uninstall -y chromium 2>/dev/null || true
    echo -e "${GREEN}[OK]${NC} 已移除 Chromium"
  fi
else
  echo -e "${YELLOW}[跳过]${NC} Chromium 未安装"
fi

# 步骤 4: 管理命令
step "4" "管理命令"

# 移除旧的 oa/oaupdate 命令 (旧版)
rm -f "${PREFIX:-}/bin/oa"
rm -f "${PREFIX:-}/bin/oaupdate"

# 移除新的管理命令
rm -f "${PREFIX:-}/bin/manage-openclaw"
rm -f "${PREFIX:-}/bin/manage-newapi"
rm -f "${PREFIX:-}/bin/status-all"
echo -e "${GREEN}[OK]${NC} 已移除所有命令"

# 步骤 5: glibc 组件
step "5" "glibc 组件"
if command -v pacman &>/dev/null && pacman -Q glibc-runner &>/dev/null; then
  if ask_yn "是否移除 glibc-runner? 这是两个平台都需要的组件。"; then
    pacman -R glibc-runner --noconfirm || true
    echo -e "${GREEN}[OK]${NC} 已移除 glibc-runner"
  else
    echo -e "${YELLOW}[保留]${NC} 保留 glibc-runner"
  fi
else
  echo -e "${YELLOW}[跳过]${NC} glibc-runner 未安装"
fi

# 步骤 6: shell 配置
step "6" "shell 配置"
BASHRC="$HOME/.bashrc"
if [ -f "$BASHRC" ]; then
  # 移除 OpenClaw 块
  if grep -qF "$BASHRC_MARKER_START" "$BASHRC" 2>/dev/null; then
    sed -i "/${BASHRC_MARKER_START//\//\/}/,/${BASHRC_MARKER_END//\//\/}/d" "$BASHRC"
    sed -i '/^$/{ N; /^\n$/d }' "$BASHRC"
    echo -e "${GREEN}[OK]${NC} 已移除 OpenClaw 环境配置"
  fi
  # 移除 NEW API PATH 行
  if grep -q "\.newapi-termux" "$BASHRC" 2>/dev/null; then
    sed -i '/\.newapi-termux/d' "$BASHRC"
    echo -e "${GREEN}[OK]${NC} 已从 .bashrc 移除 NEW API PATH"
  fi
else
  echo -e "${YELLOW}[跳过]${NC} 未找到 .bashrc"
fi

# 步骤 7: 安装目录
step "7" "安装目录"

# OpenClaw
if [ -d "$PROJECT_DIR" ]; then
  if ask_yn "是否移除 OpenClaw 安装目录 (~/.openclaw-android)?"; then
    rm -rf "$PROJECT_DIR"
    echo -e "${GREEN}[OK]${NC} 已移除 $PROJECT_DIR"
  else
    echo -e "${YELLOW}[保留]${NC} 保留 $PROJECT_DIR"
  fi
else
  echo -e "${YELLOW}[跳过]${NC} 未找到 $PROJECT_DIR"
fi

# NEW API
if [ -d "$NEWAPI_DIR" ]; then
  if ask_yn "是否移除 NEW API 数据目录 (~/.newapi-termux)?"; then
    rm -rf "$NEWAPI_DIR"
    echo -e "${GREEN}[OK]${NC} 已移除 $NEWAPI_DIR"
  else
    echo -e "${YELLOW}[保留]${NC} 保留 $NEWAPI_DIR"
    echo "  数据保留在: $NEWAPI_DIR/data/"
    echo "  日志保留在: $NEWAPI_DIR/logs/"
  fi
else
  echo -e "${YELLOW}[跳过]${NC} 未找到 $NEWAPI_DIR"
fi

echo ""
echo -e "${GREEN}${BOLD}卸载完成。${NC}"
echo "请重启 Termux 会话以清除环境变量。"
echo ""
