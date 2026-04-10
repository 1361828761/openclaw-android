#!/usr/bin/env bash
# lib.sh — 所有编排器的共享函数库
# 用法: source "$SCRIPT_DIR/scripts/lib.sh" (从仓库)
#       source "$PROJECT_DIR/scripts/lib.sh" (从已安装的副本)

# —— 颜色常量 ——
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# —— 项目常量 ——
PROJECT_DIR="$HOME/.openclaw-android"
BIN_DIR="$PROJECT_DIR/bin"
PLATFORM_MARKER="$PROJECT_DIR/.platform"
REPO_BASE_ORIGIN="https://raw.githubusercontent.com/AidanPark/openclaw-android/main"
REPO_BASE_MIRRORS=(
  "https://ghfast.top/https://raw.githubusercontent.com/AidanPark/openclaw-android/main"
  "https://ghproxy.net/https://raw.githubusercontent.com/AidanPark/openclaw-android/main"
  "https://mirror.ghproxy.com/https://raw.githubusercontent.com/AidanPark/openclaw-android/main"
)

# 检测可访问的 REPO_BASE（优先源站，然后是镜像）
resolve_repo_base() {
  if curl -sI --connect-timeout 3 "$REPO_BASE_ORIGIN/oa.sh" >/dev/null 2>&1; then
    REPO_BASE="$REPO_BASE_ORIGIN"
    return 0
  fi
  for mirror in "${REPO_BASE_MIRRORS[@]}"; do
    if curl -sI --connect-timeout 3 "$mirror/oa.sh" >/dev/null 2>&1; then
      echo -e " ${YELLOW}[镜像]${NC} 使用镜像: ${mirror%%/oa.sh*}"
      REPO_BASE="$mirror"
      return 0
    fi
  done
  # 即使不可达也回退到源站
  REPO_BASE="$REPO_BASE_ORIGIN"
  return 1
}

# 初始化 REPO_BASE
REPO_BASE="$REPO_BASE_ORIGIN"

BASHRC_MARKER_START="# >>> OpenClaw on Android >>>"
BASHRC_MARKER_END="# <<< OpenClaw on Android <<<"
OA_VERSION="1.0.22"

# —— 平台检测 ——
# 1. 显式标记文件（新安装和首次更新后）
# 2. 旧版检测（v1.0.2 及以下，一次性）
# 3. 检测失败

detect_platform() {
  if [ -f "$PLATFORM_MARKER" ]; then
    cat "$PLATFORM_MARKER"
    return 0
  fi
  if command -v openclaw &>/dev/null; then
    echo "openclaw"
    mkdir -p "$(dirname "$PLATFORM_MARKER")"
    echo "openclaw" > "$PLATFORM_MARKER"
    return 0
  fi
  echo ""
  return 1
}

# 检查特定平台是否已安装
check_platform_installed() {
  local platform="$1"
  if [ -f "$PLATFORM_MARKER" ]; then
    grep -q "^${platform}$" "$PLATFORM_MARKER" 2>/dev/null && return 0
  fi
  case "$platform" in
    openclaw) command -v openclaw &>/dev/null && return 0 ;;
    newapi) [ -x "$HOME/.newapi-termux/bin/newapi-start" ] && return 0 ;;
  esac
  return 1
}

# 检查 OpenClaw 是否已安装
check_openclaw_installed() {
  if [ -f "$PLATFORM_MARKER" ] && grep -q "^openclaw$" "$PLATFORM_MARKER" 2>/dev/null; then
    return 0
  fi
  command -v openclaw &>/dev/null && return 0
  return 1
}

# 检查 NEW API 是否已安装
check_newapi_installed() {
  if [ -f "$PLATFORM_MARKER" ] && grep -q "^newapi$" "$PLATFORM_MARKER" 2>/dev/null; then
    return 0
  fi
  [ -x "$HOME/.newapi-termux/bin/newapi-start" ] && return 0
  return 1
}

# —— 平台名称验证 ——
validate_platform_name() {
  local name="$1"
  if [ -z "$name" ]; then
    echo -e "${RED}[失败]${NC} 平台名称为空"
    return 1
  fi
  # 只允许小写字母数字 + 连字符/下划线
  if [[ ! "$name" =~ ^[a-z0-9][a-z0-9_-]*$ ]]; then
    echo -e "${RED}[失败]${NC} 无效的平台名称: $name"
    return 1
  fi
  return 0
}

# —— 用户确认提示 ——
# 从 /dev/tty 读取以便在 curl|bash 模式下也能工作。
ask_yn() {
  local prompt="$1"
  local reply
  if (echo -n "" > /dev/tty) 2>/dev/null; then
    read -rp "$prompt [Y/n] " reply < /dev/tty
  else
    read -rp "$prompt [Y/n] " reply
  fi
  [[ "${reply:-}" =~ ^[Nn]$ ]] && return 1
  return 0
}

# —— 加载平台 config.env ——
# $1: 平台名称, $2: 基础目录（platforms/ 的父目录）
load_platform_config() {
  local platform="$1"
  local base_dir="$2"
  local config_path="$base_dir/platforms/$platform/config.env"

  validate_platform_name "$platform" || return 1

  if [ ! -f "$config_path" ]; then
    echo -e "${RED}[失败]${NC} 未找到平台配置: $config_path"
    return 1
  fi
  # shellcheck source=/dev/null
  source "$config_path"
  return 0
}

# —— NEW API 助手 ——
NEWAPI_DIR="$HOME/.newapi-termux"
NEWAPI_BIN_DIR="$NEWAPI_DIR/bin"

newapi_get_port() {
  if [ -f "$NEWAPI_DIR/newapi.pid" ]; then
    PID=$(cat "$NEWAPI_DIR/newapi.pid" 2>/dev/null) || return 1
    netstat -tlnp 2>/dev/null | grep "$PID" | grep -o ':[0-9]*' | head -1 | tr -d ':'
  fi
}

newapi_is_running() {
  if [ -f "$NEWAPI_DIR/newapi.pid" ]; then
    PID=$(cat "$NEWAPI_DIR/newapi.pid" 2>/dev/null) || return 1
    kill -0 "$PID" 2>/dev/null
  else
    return 1
  fi
}
