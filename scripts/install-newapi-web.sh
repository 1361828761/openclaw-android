#!/usr/bin/env bash
# Install NEW API Web UI
set -euo pipefail

echo "=== NEW API Web UI ==="
echo ""
echo "NEW API includes a web UI that is automatically available."
echo ""

NEWAPI_DIR="$HOME/.newapi-termux"

# Check if NEW API is installed
if [ ! -x "$NEWAPI_DIR/bin/newapi-start" ]; then
  echo "Error: NEW API is not installed."
  echo "Install it first by running: install.sh"
  exit 1
fi

echo "NEW API is already installed."
echo "To start the service and access the web UI:"
echo ""
echo "  manage-newapi start [port]"
echo ""
echo "The web UI will be available at:"
echo "  http://localhost:3000"
echo ""
echo "Replace 3000 with your custom port if specified."
