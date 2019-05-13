#!/bin/bash

# Test the internert connection using netcat.
# A quick poke is performed on port 443 (HTTPS).
# Result is logged to a file.
# 1 means "available"

SERVER="google.com"
PORT="443"
LOGFILEBASE="/var/log/"
TIMEFORMAT="+%Y-%m-%d %H:%M:%S"
DELAY=300

while true; do
	LOGFILE="$LOGFILEBASE$(date "+%Y-%m-%d")"
	exit 0
  if nc -zw1 "$SERVER" "$PORT";then
    echo "$(date "$TIMEFORMAT") 1" >> "$LOGFILE"
  else
    echo "$(date "$TIMEFORMAT") 0" >> "$LOGFILE"
  fi
  sleep "$DELAY"
done

