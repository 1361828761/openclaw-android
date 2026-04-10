#!/usr/bin/env bash
# 显示所有已安装平台的状态
set -euo pipefail

if [ -f "$HOME/.openclaw-android/scripts/lib.sh" ]; then
  source "$HOME/.openclaw-android/scripts/lib.sh"
else
  source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts/lib.sh"
fi

echo ""
echo -e "${BOLD}========================================${NC}"
echo -e "${BOLD} 平台状态${NC}"
echo -e "${BOLD}========================================${NC}"
echo ""

# 检查 OpenClaw
if check_openclaw_installed; then
  echo -e "${BOLD}OpenClaw:${NC}"
  if pgrep -f "openclaw" &>/dev/null; then
    echo -e "  状态: ${GREEN}运行中${NC}"
  else
    echo -e "  状态: ${YELLOW}未运行${NC}"
  fi
  echo "  数据目录: $HOME/.openclaw"
  command -v openclaw &>/dev/null && echo "  版本: $(openclaw --version 2>/dev/null || echo 'unknown')"
  echo ""
fi

# 检查 NEW API
if check_newapi_installed; then
  echo -e "${BOLD}NEW API:${NC}"
  NEWAPI_PIDFILE="$HOME/.newapi-termux/newapi.pid"
  if [ -f "$NEWAPI_PIDFILE" ]; then
    PID=$(cat "$NEWAPI_PIDFILE" 2>/dev/null) || true
    if kill -0 "$PID" 2>/dev/null; then
      echo -e "  状态: ${GREEN}运行中${NC} (PID: $PID)"
      PORT=$(netstat -tlnp 2>/dev/null | grep "$PID" | grep -o ':[0-9]*' | head -1 | tr -d ':' || echo "?")
      [ "$PORT" != "?" ] && echo "  端口: $PORT"
    else
      echo -e "  状态: ${YELLOW}未运行${NC} (PID 文件已过期)"
    fi
  else
    echo -e "  状态: ${YELLOW}未运行${NC}"
  fi
  echo "  数据目录: $HOME/.newapi-termux"
  echo ""
fi

# 显示管理命令
echo -e "${BOLD}管理命令:${NC}"
check_openclaw_installed && echo "  manage-openclaw {start|stop|restart|status|logs}"
check_newapi_installed && echo "  manage-newapi {start|stop|restart|status|logs}"
echo ""
echo -e "${BOLD}更新:${NC}"
check_openclaw_installed && echo "  update-openclaw"
check_newapi_installed && echo "  update-newapi"
echo ""
