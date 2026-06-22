#!/bin/sh
set -euo pipefail

# Parse env vars into flags
MAC="${MAC:-$LS_WOL_MAC}"
UPSTREAM="${UPSTREAM:-$LS_WOL_UPSTREAM}"
TIMEOUT="${TIMEOUT:-${LS_WOL_TIMEOUT:-60}}"
LISTEN="${LISTEN:-${LS_WOL_LISTEN:-8080}}"
LOG="${LOG:-${LS_WOL_LOG:-info}}"

# 1. Handle Certificate Injection (Runtime)
# Users can mount certificates into this directory to trust self-signed upstreams
CERT_DIR="/usr/local/share/ca-certificates"
if [ -f "$CERT_DIR/upstream.crt" ]; then
  echo "Found custom certificate in $CERT_DIR. Updating trust store..."
  update-ca-certificates
  echo "Trust store updated."
else
  echo "No custom certificates found. Using system defaults."
fi

# 2. Validate required arguments
if [ -z "$MAC" ] || [ -z "$UPSTREAM" ]; then
  echo "Error: MAC and UPSTREAM environment variables are required."
  echo "Usage:"
  echo "  docker run -e MAC=XX:XX:XX:XX:XX:XX -e UPSTREAM=https://example.com ls-wol-proxy"
  echo ""
  echo "To use self-signed certificates, mount your cert to:"
  echo "  -v /path/to/cert.crt:/usr/local/share/ca-certificates/upstream.crt:ro"
  exit 1
fi

# 3. Run the proxy as the 'alpine' user
echo "Starting wol-proxy as non-root user..."

# Build arguments
ARGS="-mac $MAC -upstream $UPSTREAM -timeout $TIMEOUT -listen $LISTEN -log $LOG"

exec su-exec alpine /ls-wol-proxy $ARGS
