#!/usr/bin/env bash
# OpenClaw 管理脚本
set -euo pipefail

PROJECT_DIR="$HOME/.openclaw-android"
PLATFORM_DIR="$HOME/.openclaw"

show_help() {
  echo "OpenClaw 管理脚本"
  echo ""
  echo "用法: manage-openclaw {start|stop|restart|status|logs|help}"
  echo ""
  echo "命令:"
  echo "  start    启动 OpenClaw 服务"
  echo "  stop     停止 OpenClaw 服务"
  echo "  restart  重启 OpenClaw 服务"
  echo "  status   显示 OpenClaw 状态"
  echo "  logs     显示 OpenClaw 日志"
  echo "  help     显示此帮助"
}

cmd_start() {
  if command -v openclaw &>/dev/null; then
    openclaw gateway &
    echo "OpenClaw 网关已启动"
  else
    echo "错误: 未找到 openclaw 命令"
    exit 1
  fi
}

cmd_stop() {
  pkill -f "openclaw gateway" 2>/dev/null || true
  echo "OpenClaw 已停止"
}

cmd_restart() {
  cmd_stop
  sleep 1
  cmd_start
}

cmd_status() {
  if pgrep -f "openclaw" &>/dev/null; then
    echo "OpenClaw: 运行中"
    pgrep -f "openclaw"
  else
    echo "OpenClaw: 未运行"
  fi
}

cmd_logs() {
  if [ -d "$PLATFORM_DIR/logs" ]; then
    tail -f "$PLATFORM_DIR/logs/"*.log 2>/dev/null || echo "未找到日志"
  else
    echo "日志目录不存在"
  fi
}

case "${1:-help}" in
  start) cmd_start ;;
  stop) cmd_stop ;;
  restart) cmd_restart ;;
  status) cmd_status ;;
  logs) cmd_logs ;;
  help|--help|-h) show_help ;;
  *)
    echo "未知命令: $1"
    show_help
    exit 1
    ;;
esac
