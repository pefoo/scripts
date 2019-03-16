#!/bin/bash

# Test the internert connection using netcat.
# A quick poke is performed on port 443 (HTTPS).
# Result is logged to a file.
# 1 means "available"

SERVER="google.com"
PORT="443"
LOGFILE="$HOME/logs/inet_connectivity"
TIMEFORMAT="+%Y-%m-%d %H:%M:%S"

mkdir -p $(dirname "$LOGFILE")

if nc -zw1 "$SERVER" "$PORT";then
  echo "$(date "$TIMEFORMAT") 1" >> "$LOGFILE"
else
  echo "$(date "$TIMEFORMAT") 0" >> "$LOGFILE"
fi

