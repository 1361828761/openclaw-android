#!/usr/bin/env bash
# NEW API 管理脚本
set -euo pipefail

PROJECT_DIR="$HOME/.newapi-termux"
BIN_DIR="$PROJECT_DIR/bin"

show_help() {
  echo "NEW API 管理脚本"
  echo ""
  echo "用法: manage-newapi {start|stop|restart|status|logs|help} [端口]"
  echo ""
  echo "命令:"
  echo "  start [端口]   启动 NEW API (默认端口: 3000)"
  echo "  stop           停止 NEW API"
  echo "  restart        重启 NEW API"
  echo "  status         显示 NEW API 状态"
  echo "  logs           显示 NEW API 日志"
  echo "  help           显示此帮助"
}

cmd_start() {
  local port="${1:-3000}"
  if [ -x "$BIN_DIR/newapi-start" ]; then
    "$BIN_DIR/newapi-start" "$port"
  else
    echo "错误: 未找到 newapi-start"
    echo "NEW API 可能未安装"
    exit 1
  fi
}

cmd_stop() {
  if [ -x "$BIN_DIR/newapi-stop" ]; then
    "$BIN_DIR/newapi-stop"
  else
    echo "错误: 未找到 newapi-stop"
    exit 1
  fi
}

cmd_restart() {
  cmd_stop
  sleep 1
  local port="${1:-3000}"
  cmd_start "$port"
}

cmd_status() {
  if [ -x "$BIN_DIR/newapi-status" ]; then
    "$BIN_DIR/newapi-status"
  else
    echo "错误: 未找到 newapi-status"
    exit 1
  fi
}

cmd_logs() {
  local logfile="$PROJECT_DIR/logs/newapi.log"
  if [ -f "$logfile" ]; then
    tail -f "$logfile"
  else
    echo "日志文件不存在: $logfile"
    exit 1
  fi
}

case "${1:-help}" in
  start)
    port="${2:-3000}"
    cmd_start "$port"
    ;;
  stop) cmd_stop ;;
  restart)
    port="${2:-3000}"
    cmd_restart "$port"
    ;;
  status) cmd_status ;;
  logs) cmd_logs ;;
  help|--help|-h) show_help ;;
  *)
    echo "未知命令: $1"
    show_help
    exit 1
    ;;
esac
