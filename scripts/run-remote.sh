#!/bin/bash
# Usage:
#   ./run-remote.sh <IP_ADDRESS> <SSH_KEY_PATH> <USERNAME> <LOCAL_SCRIPT.sh>

set -e

IP="$1"
KEY="$2"
USER="$3"
SCRIPT="$4"

if [[ -z "$IP" || -z "$KEY" || -z "$USER" || -z "$SCRIPT" ]]; then
  echo "Usage: $0 <IP> <key.pem> <user> <script.sh>"
  exit 1
fi

if [[ ! -f "$SCRIPT" ]]; then
  echo "❌ Local script not found: $SCRIPT"
  exit 1
fi

echo "🚀 Running $SCRIPT on $USER@$IP..."
ssh -i "$KEY" -o StrictHostKeyChecking=no "$USER@$IP" 'bash -s' < "$SCRIPT"
