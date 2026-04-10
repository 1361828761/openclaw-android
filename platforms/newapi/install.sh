#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/../scripts/lib.sh"

echo "=== Installing NEW API ==="
NEWAPI_VERSION="v0.12.6"
NEWAPI_DIR="$HOME/.newapi-termux"
BIN_DIR="$NEWAPI_DIR/bin"
NEWAPI_BIN="$BIN_DIR/newapi"
GLIBC_LDSO="$PREFIX/glibc/lib/ld-linux-aarch64.so.1"

mkdir -p "$BIN_DIR" "$NEWAPI_DIR"/{data,logs,backup,scripts}

# 复制脚本文件
cp "$SCRIPT_DIR/../scripts/lib.sh" "$NEWAPI_DIR/scripts/"
[ -f "$SCRIPT_DIR/../scripts/backup.sh" ] && cp "$SCRIPT_DIR/../scripts/backup.sh" "$NEWAPI_DIR/scripts/"
chmod +x "$NEWAPI_DIR/scripts/"*.sh 2>/dev/null || true

# 下载二进制
if [ ! -f "$NEWAPI_BIN" ]; then
  echo "Downloading NEW API $NEWAPI_VERSION..."
  URL="https://github.com/QuantumNous/new-api/releases/download/${NEWAPI_VERSION}/new-api-arm64-${NEWAPI_VERSION}"
  if ! curl -fL --max-time 300 -o "$NEWAPI_BIN.tmp" "$URL" 2>/dev/null; then
    echo "Primary URL failed, trying mirror..."
    curl -fL --max-time 300 -o "$NEWAPI_BIN.tmp" "https://ghfast.top/$URL" || {
      echo -e "${RED}[FAIL]${NC} Download failed"
      exit 1
    }
  fi
  mv "$NEWAPI_BIN.tmp" "$NEWAPI_BIN"
  chmod +x "$NEWAPI_BIN"
  echo -e "${GREEN}[OK]${NC} Download complete"
fi

# 创建wrapper
cat > "$BIN_DIR/newapi-run" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
unset LD_PRELOAD
export HOME="$HOME"
export NEWAPI_DATA_DIR="$HOME/.newapi-termux/data"
export NEWAPI_LOG_DIR="$HOME/.newapi-termux/logs"
export NEWAPI_PORT="${NEWAPI_PORT:-3000}"
GLIBC_LDSO="$PREFIX/glibc/lib/ld-linux-aarch64.so.1"
NEWAPI_BIN="$HOME/.newapi-termux/bin/newapi"
exec "$GLIBC_LDSO" --library-path "$PREFIX/glibc/lib" "$NEWAPI_BIN" "$@"
EOF
chmod +x "$BIN_DIR/newapi-run"

# 创建启动脚本
cat > "$BIN_DIR/newapi-start" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
PROJECT_DIR="$HOME/.newapi-termux"; BIN="$PROJECT_DIR/bin"
PIDFILE="$PROJECT_DIR/newapi.pid"; PORT="${1:-3000}"
if [ -f "$PIDFILE" ]; then
  PID=$(cat "$PIDFILE" 2>/dev/null) || true
  if kill -0 "$PID" 2>/dev/null; then
    echo "Already running (PID: $PID)"
    exit 0
  else
    rm -f "$PIDFILE"
  fi
fi
mkdir -p "$PROJECT_DIR/logs"
nohup "$BIN/newapi-run" --port "$PORT" >> "$PROJECT_DIR/logs/newapi.log" 2>&1 &
echo $! > "$PIDFILE"
sleep 2
if kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  echo -e "${GREEN}[OK]${NC} Started: http://localhost:$PORT"
else
  echo -e "${RED}[FAIL]${NC} Start failed"
  rm -f "$PIDFILE"
  exit 1
fi
EOF
chmod +x "$BIN_DIR/newapi-start"

# 创建停止脚本
cat > "$BIN_DIR/newapi-stop" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
PIDFILE="$HOME/.newapi-termux/newapi.pid"
if [ -f "$PIDFILE" ]; then
  PID=$(cat "$PIDFILE" 2>/dev/null) || true
  if kill "$PID" 2>/dev/null; then
    echo "Stopped"
  else
    echo "Process not running"
  fi
  rm -f "$PIDFILE"
else
  echo "Not running"
fi
EOF
chmod +x "$BIN_DIR/newapi-stop"

# 创建状态脚本
cat > "$BIN_DIR/newapi-status" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
GREEN='\033[0;32m'; YELLOW='\033[0;33m'; NC='\033[0m'
PIDFILE="$HOME/.newapi-termux/newapi.pid"
if [ -f "$PIDFILE" ]; then
  PID=$(cat "$PIDFILE" 2>/dev/null) || true
  if kill -0 "$PID" 2>/dev/null; then
    echo -e "${GREEN}Running${NC} (PID: $PID)"
    # Try to get port
    PORT=$(netstat -tlnp 2>/dev/null | grep "$PID" | grep -o ':[0-9]*' | head -1 | tr -d ':' || echo "?")
    [ "$PORT" != "?" ] && echo "Port: $PORT"
  else
    echo -e "${YELLOW}Not running${NC} (stale PID file)"
    rm -f "$PIDFILE"
  fi
else
  echo -e "${YELLOW}Not running${NC}"
fi
EOF
chmod +x "$BIN_DIR/newapi-status"

# 创建日志脚本
cat > "$BIN_DIR/newapi-logs" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
LOGFILE="$HOME/.newapi-termux/logs/newapi.log"
if [ -f "$LOGFILE" ]; then
  tail -f "$LOGFILE"
else
  echo "Log file not found: $LOGFILE"
  exit 1
fi
EOF
chmod +x "$BIN_DIR/newapi-logs"

# 重启动脚本
cat > "$BIN_DIR/newapi-restart" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
BIN="$HOME/.newapi-termux/bin"
PORT="${1:-3000}"
"$BIN/newapi-stop" 2>/dev/null || true
sleep 1
"$BIN/newapi-start" "$PORT"
EOF
chmod +x "$BIN_DIR/newapi-restart"

# 创建平台标记
echo "newapi" > "$NEWAPI_DIR/.platform"

echo -e "${GREEN}[OK]${NC} NEW API installed"
echo "Commands: newapi-start [port] | newapi-stop | newapi-status | newapi-logs"
