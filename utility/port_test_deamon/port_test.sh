#!/bin/bash

# Test ssh connection using netcat
# A quick poke is performed on port 22
# Result is logged to a file.
# 1 means "available"

SERVER="markusgruber.ddns.net"
PORT="22"
LOGFILEBASE="/var/log/ssh_server_availability/"
TIMEFORMAT="+%Y-%m-%d %H:%M:%S"
DELAY=300

mkdir -p "$LOGFILEBASE"

while true; do
	LOGFILE="$LOGFILEBASE$(date "+%Y-%m-%d")"
  if nc -zw 5 "$SERVER" "$PORT";then
    echo "$(date "$TIMEFORMAT") 1" >> "$LOGFILE"
  else
    echo "$(date "$TIMEFORMAT") 0" >> "$LOGFILE"
  fi
  sleep "$DELAY"
done

