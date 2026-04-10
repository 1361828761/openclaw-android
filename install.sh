#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/lib.sh"

echo ""
echo -e "${BOLD}========================================${NC}"
echo -e "${BOLD} 统一 AI 平台安装器 v${OA_VERSION}${NC}"
echo -e "${BOLD}========================================${NC}"
echo ""
echo "本脚本将在 Termux 中安装 OpenClaw 和/或 NEW API"
echo ""

step() {
  echo ""
  echo -e "${BOLD}[$1/8] $2${NC}"
  echo "----------------------------------------"
}

step 1 "环境检查"
if command -v termux-wake-lock &>/dev/null; then
  termux-wake-lock 2>/dev/null || true
  echo -e "${GREEN}[OK]${NC} Termux 唤醒锁已启用"
fi
bash "$SCRIPT_DIR/scripts/check-env.sh"

step 2 "平台选择"
INSTALL_OPENCLAW=false
INSTALL_NEWAPI=false

if ask_yn "是否安装 OpenClaw?"; then INSTALL_OPENCLAW=true; fi
if ask_yn "是否安装 NEW API?"; then INSTALL_NEWAPI=true; fi

if [ "$INSTALL_OPENCLAW" = false ] && [ "$INSTALL_NEWAPI" = false ]; then
  echo -e "${RED}[失败]${NC} 未选择任何平台，退出。"
  exit 1
fi

echo ""
echo -e "${GREEN}[OK]${NC} 已选择的平台:"
[ "$INSTALL_OPENCLAW" = true ] && echo " - OpenClaw"
[ "$INSTALL_NEWAPI" = true ] && echo " - NEW API"

step 3 "可选工具选择 (L3)"
INSTALL_TMUX=false
INSTALL_TTYD=false
INSTALL_DUFS=false
INSTALL_ANDROID_TOOLS=false
INSTALL_CODE_SERVER=false
INSTALL_OPENCODE=false
INSTALL_CLAUDE_CODE=false
INSTALL_GEMINI_CLI=false
INSTALL_CODEX_CLI=false
INSTALL_CHROMIUM=false

if ask_yn "安装 tmux (终端复用器)?"; then INSTALL_TMUX=true; fi
if ask_yn "安装 ttyd (网页终端)?"; then INSTALL_TTYD=true; fi
if ask_yn "安装 dufs (文件服务器)?"; then INSTALL_DUFS=true; fi
if ask_yn "安装 android-tools (adb)?"; then INSTALL_ANDROID_TOOLS=true; fi
if ask_yn "安装 Chromium (浏览器自动化，~400MB)?"; then INSTALL_CHROMIUM=true; fi
if ask_yn "安装 code-server (浏览器 IDE)?"; then INSTALL_CODE_SERVER=true; fi
if ask_yn "安装 OpenCode (AI 编程助手)?"; then INSTALL_OPENCODE=true; fi
if ask_yn "安装 Claude Code CLI?"; then INSTALL_CLAUDE_CODE=true; fi
if ask_yn "安装 Gemini CLI?"; then INSTALL_GEMINI_CLI=true; fi
if ask_yn "安装 Codex CLI?"; then INSTALL_CODEX_CLI=true; fi

step 4 "核心基础设施 (L1)"
bash "$SCRIPT_DIR/scripts/install-infra-deps.sh"
bash "$SCRIPT_DIR/scripts/setup-paths.sh"

step 5 "平台运行时依赖 (L2)"
if [ "$INSTALL_OPENCLAW" = true ]; then
  load_platform_config "openclaw" "$SCRIPT_DIR"
fi
if [ "$INSTALL_NEWAPI" = true ]; then
  load_platform_config "newapi" "$SCRIPT_DIR"
fi

if [ "$INSTALL_OPENCLAW" = true ]; then
  if [ "${PLATFORM_NEEDS_GLIBC:-true}" = true ]; then bash "$SCRIPT_DIR/scripts/install-glibc.sh"; fi
  if [ "${PLATFORM_NEEDS_NODEJS:-true}" = true ]; then bash "$SCRIPT_DIR/scripts/install-nodejs.sh"; fi
  if [ "${PLATFORM_NEEDS_BUILD_TOOLS:-true}" = true ]; then bash "$SCRIPT_DIR/scripts/install-build-tools.sh"; fi
fi

if [ "$INSTALL_NEWAPI" = true ]; then
  bash "$SCRIPT_DIR/scripts/install-glibc.sh"
fi

# 为当前会话设置环境变量
GLIBC_BIN_DIR="$PROJECT_DIR/bin"
GLIBC_NODE_DIR="$PROJECT_DIR/node"
export PATH="$GLIBC_BIN_DIR:$GLIBC_NODE_DIR/bin:$HOME/.local/bin:$PATH"
export TMPDIR="$PREFIX/tmp"
export TMP="$TMPDIR"
export TEMP="$TMPDIR"
export OA_GLIBC=1

step 6 "平台包安装 (L2)"
[ "$INSTALL_OPENCLAW" = true ] && bash "$SCRIPT_DIR/platforms/openclaw/install.sh"
[ "$INSTALL_NEWAPI" = true ] && bash "$SCRIPT_DIR/platforms/newapi/install.sh"

echo ""
echo -e "${BOLD}[6.5] 环境变量 + CLI + 标记${NC}"
echo "----------------------------------------"
bash "$SCRIPT_DIR/scripts/setup-env.sh"

if [ "$INSTALL_OPENCLAW" = true ]; then
  PLATFORM_ENV_SCRIPT="$SCRIPT_DIR/platforms/openclaw/env.sh"
  if [ -f "$PLATFORM_ENV_SCRIPT" ]; then
    eval "$(bash "$PLATFORM_ENV_SCRIPT")"
  fi
fi

mkdir -p "$PROJECT_DIR"

# 创建已安装平台的标记
[ "$INSTALL_OPENCLAW" = true ] && echo "openclaw" >> "$PLATFORM_MARKER"
[ "$INSTALL_NEWAPI" = true ] && echo "newapi" >> "$PLATFORM_MARKER"

# 复制管理脚本
cp "$SCRIPT_DIR/manage-openclaw.sh" "$PREFIX/bin/manage-openclaw" 2>/dev/null || true
cp "$SCRIPT_DIR/manage-newapi.sh" "$PREFIX/bin/manage-newapi" 2>/dev/null || true
chmod +x "$PREFIX/bin/manage-openclaw" "$PREFIX/bin/manage-newapi" 2>/dev/null || true

cp "$SCRIPT_DIR/update-openclaw.sh" "$PROJECT_DIR/update-openclaw.sh" 2>/dev/null || true
cp "$SCRIPT_DIR/update-newapi.sh" "$PROJECT_DIR/update-newapi.sh" 2>/dev/null || true
cp "$SCRIPT_DIR/status-all.sh" "$PREFIX/bin/status-all" 2>/dev/null || true
chmod +x "$PREFIX/bin/status-all" "$PROJECT_DIR/"*.sh 2>/dev/null || true

cp "$SCRIPT_DIR/uninstall.sh" "$PROJECT_DIR/uninstall.sh"
chmod +x "$PROJECT_DIR/uninstall.sh"

mkdir -p "$PROJECT_DIR/scripts"
mkdir -p "$PROJECT_DIR/platforms"
cp "$SCRIPT_DIR/scripts/lib.sh" "$PROJECT_DIR/scripts/lib.sh"
cp "$SCRIPT_DIR/scripts/setup-env.sh" "$PROJECT_DIR/scripts/setup-env.sh"
cp "$SCRIPT_DIR/scripts/backup.sh" "$PROJECT_DIR/scripts/backup.sh"

# 复制平台文件
rm -rf "$PROJECT_DIR/platforms/openclaw"
cp -R "$SCRIPT_DIR/platforms/openclaw" "$PROJECT_DIR/platforms/openclaw"

if [ "$INSTALL_NEWAPI" = true ]; then
  rm -rf "$PROJECT_DIR/platforms/newapi"
  cp -R "$SCRIPT_DIR/platforms/newapi" "$PROJECT_DIR/platforms/newapi"
fi

step 7 "安装可选工具 (L3)"
if [ "$INSTALL_TMUX" = true ]; then pkg install -y tmux; fi
if [ "$INSTALL_TTYD" = true ]; then pkg install -y ttyd; fi
if [ "$INSTALL_DUFS" = true ]; then pkg install -y dufs; fi
if [ "$INSTALL_ANDROID_TOOLS" = true ]; then pkg install -y android-tools; fi

if [ "$INSTALL_CHROMIUM" = true ]; then bash "$SCRIPT_DIR/scripts/install-chromium.sh" install; fi

if [ "$INSTALL_CODE_SERVER" = true ]; then mkdir -p "$PROJECT_DIR/patches" && cp "$SCRIPT_DIR/patches/argon2-stub.js" "$PROJECT_DIR/patches/argon2-stub.js" && bash "$SCRIPT_DIR/scripts/install-code-server.sh" install; fi

if [ "$INSTALL_OPENCODE" = true ]; then bash "$SCRIPT_DIR/scripts/install-opencode.sh" install; fi

if [ "$INSTALL_CLAUDE_CODE" = true ]; then npm install -g @anthropic-ai/claude-code; fi
if [ "$INSTALL_GEMINI_CLI" = true ]; then npm install -g @google/gemini-cli; fi
if [ "$INSTALL_CODEX_CLI" = true ]; then npm install -g @openai/codex; fi

step 8 "验证"
bash "$SCRIPT_DIR/tests/verify-install.sh"

echo ""
echo -e "${BOLD}========================================${NC}"
echo -e "${GREEN}${BOLD} 安装完成！${NC}"
echo -e "${BOLD}========================================${NC}"
echo ""
[ "$INSTALL_OPENCLAW" = true ] && echo -e " ${BOLD}OpenClaw:${NC} 运行 'manage-openclaw start' 启动"
[ "$INSTALL_NEWAPI" = true ] && echo -e " ${BOLD}NEW API:${NC} 运行 'manage-newapi start [端口]' 启动"
echo ""
echo "管理命令:"
echo "manage-openclaw {start|stop|restart|status|logs}"
echo "manage-newapi {start|stop|restart|status|logs}"
echo "status-all"
echo ""
