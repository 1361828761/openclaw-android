#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/lib.sh"

PASS=0
FAIL=0
WARN=0

check_pass() {
 echo -e "${GREEN}[PASS]${NC} $1"
 PASS=$((PASS + 1))
}

check_fail() {
 echo -e "${RED}[FAIL]${NC} $1"
 FAIL=$((FAIL + 1))
}

check_warn() {
 echo -e "${YELLOW}[WARN]${NC} $1"
 WARN=$((WARN + 1))
}

# 检测已安装的平台
INSTALLED_PLATFORMS=()
if [ -f "$PLATFORM_MARKER" ]; then
 while IFS= read -r line; do
  [ -n "$line" ] && INSTALLED_PLATFORMS+=("$line")
 done < "$PLATFORM_MARKER"
fi

echo "=== 统一 AI 平台 - 安装验证 ==="
echo ""

# 检查是否安装了 OpenClaw
HAS_OPENCLAW=false
HAS_NEWAPI=false

for platform in "${INSTALLED_PLATFORMS[@]}"; do
 case "$platform" in
  openclaw) HAS_OPENCLAW=true ;;
  newapi) HAS_NEWAPI=true ;;
 esac
done

echo "已安装的平台: ${INSTALLED_PLATFORMS[*]:-无}"
echo ""

# OpenClaw 验证项目
if [ "$HAS_OPENCLAW" = true ]; then
 if command -v node &>/dev/null; then
  NODE_VER=$(node -v)
  NODE_MAJOR="${NODE_VER%%.*}"
  NODE_MAJOR="${NODE_MAJOR#v}"
  if [ "$NODE_MAJOR" -ge 22 ] 2>/dev/null; then
   check_pass "Node.js $NODE_VER (>= 22)"
  else
   check_fail "Node.js $NODE_VER (need >= 22)"
  fi
 else
  check_fail "Node.js not found (OpenClaw 需要)"
 fi

 if command -v npm &>/dev/null; then
  check_pass "npm $(npm -v)"
 else
  check_fail "npm not found (OpenClaw 需要)"
 fi

 COMPAT_FILE="$PROJECT_DIR/patches/glibc-compat.js"
 if [ -f "$COMPAT_FILE" ]; then
  check_pass "glibc-compat.js exists"
 else
  check_fail "glibc-compat.js not found at $COMPAT_FILE"
 fi

 NODE_WRAPPER="$BIN_DIR/node"
 if [ -f "$NODE_WRAPPER" ] && head -1 "$NODE_WRAPPER" 2>/dev/null | grep -q "bash"; then
  check_pass "glibc node wrapper script"
 else
  check_fail "glibc node wrapper not found or not a wrapper script"
 fi

 # OpenClaw 特定验证
 if [ -x "$PROJECT_DIR/bin/openclaw" ]; then
  check_pass "OpenClaw 已安装"
 else
  check_fail "OpenClaw 未正确安装"
 fi
fi

# NEW API 验证项目
if [ "$HAS_NEWAPI" = true ]; then
 NEWAPI_DIR="$HOME/.newapi-termux"
 NEWAPI_BIN="$NEWAPI_DIR/bin/newapi"

 if [ -f "$NEWAPI_BIN" ]; then
  check_pass "NEW API 二进制文件存在"
 else
  check_fail "NEW API 二进制文件未找到"
 fi

 if [ -x "$NEWAPI_DIR/bin/newapi-start" ]; then
  check_pass "NEW API 启动脚本存在"
 else
  check_fail "NEW API 启动脚本未找到"
 fi
fi

# 通用验证项目
if [ -n "${TMPDIR:-}" ]; then
 check_pass "TMPDIR=$TMPDIR"
else
 check_fail "TMPDIR not set"
fi

if [ "${OA_GLIBC:-}" = "1" ]; then
 check_pass "OA_GLIBC=1 (glibc 架构)"
else
 # 如果只安装了 NEW API 也应该有 glibc
 if [ "$HAS_NEWAPI" = true ]; then
  GLIBC_LDSO="${PREFIX:-}/glibc/lib/ld-linux-aarch64.so.1"
  if [ -f "$GLIBC_LDSO" ]; then
   check_pass "glibc dynamic linker (ld-linux-aarch64.so.1)"
  else
   check_fail "glibc dynamic linker not found at $GLIBC_LDSO"
  fi
 else
  check_fail "OA_GLIBC not set"
 fi
fi

GLIBC_MARKER="$PROJECT_DIR/.glibc-arch"
if [ -f "$GLIBC_MARKER" ]; then
 check_pass "glibc architecture marker (.glibc-arch)"
else
 if [ "$HAS_NEWAPI" = true ]; then
  check_warn "glibc architecture marker not found (NEW API 独立运行)"
 fi
fi

for DIR in "$PROJECT_DIR" "$PREFIX/tmp"; do
 if [ -d "$DIR" ]; then
  check_pass "Directory $DIR exists"
 else
  check_fail "Directory $DIR missing"
 fi
done

if command -v code-server &>/dev/null; then
 CS_VER=$(code-server --version 2>/dev/null | head -1 || true)
 if [ -n "$CS_VER" ]; then
  check_pass "code-server $CS_VER"
 else
  check_warn "code-server found but --version failed"
 fi
else
 check_warn "code-server not installed (non-critical)"
fi

if command -v opencode &>/dev/null; then
 check_pass "opencode command available"
else
 check_warn "opencode not installed (non-critical)"
fi

if grep -qF "OpenClaw on Android" "$HOME/.bashrc" 2>/dev/null || grep -qF "统一 AI 平台" "$HOME/.bashrc" 2>/dev/null; then
 check_pass ".bashrc contains environment block"
else
 check_fail ".bashrc missing environment block"
fi

# 平台特定验证器
for platform in "${INSTALLED_PLATFORMS[@]}"; do
 PLATFORM_VERIFY="$PROJECT_DIR/platforms/$platform/verify.sh"
 if [ -n "$platform" ] && [ -f "$PLATFORM_VERIFY" ]; then
  if bash "$PLATFORM_VERIFY"; then
   check_pass "Platform verifier passed ($platform)"
  else
   check_fail "Platform verifier failed ($platform)"
  fi
 else
  check_warn "Platform verifier not found (platform=$platform)"
 fi
done

# 如果安装了多个平台，给出额外提示
if [ "$HAS_OPENCLAW" = true ] && [ "$HAS_NEWAPI" = true ]; then
 echo ""
 echo -e "${BLUE}提示: 已安装 OpenClaw 和 NEW API${NC}"
 echo "  - OpenClaw 管理: manage-openclaw {start|stop|status|logs}"
 echo "  - NEW API 管理: manage-newapi {start|stop|status|logs}"
 echo "  - 查看所有状态: status-all"
fi

echo ""
echo "==============================="
echo -e " Results: ${GREEN}$PASS passed${NC}, ${RED}$FAIL failed${NC}, ${YELLOW}$WARN warnings${NC}"
echo "==============================="
echo ""

# 如果没有安装任何平台，验证失败
if [ ${#INSTALLED_PLATFORMS[@]} -eq 0 ]; then
 echo -e "${RED}未检测到已安装的平台${NC}"
 exit 1
fi

if [ "$FAIL" -gt 0 ]; then
 echo -e "${RED}Installation verification FAILED.${NC}"
 echo "Please check the errors above and re-run install.sh"
 exit 1
else
 echo -e "${GREEN}Installation verification PASSED!${NC}"
fi