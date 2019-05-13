#!/bin/bash

# Test the internert connection using netcat.
# A quick poke is performed on port 443 (HTTPS).
# Result is logged to a file.
# 1 means "available"

SERVER="google.com"
PORT="443"
LOGFILEBASE="/var/log/internet_connection/"
TIMEFORMAT="+%Y-%m-%d %H:%M:%S"
DELAY=300

mkdir -p "$LOGFILEBASE"

while true; do
	LOGFILE="$LOGFILEBASE$(date "+%Y-%m-%d")"
  if nc -zw1 "$SERVER" "$PORT";then
    echo "$(date "$TIMEFORMAT") 1" >> "$LOGFILE"
  else
    echo "$(date "$TIMEFORMAT") 0" >> "$LOGFILE"
  fi
  sleep "$DELAY"
done

