#!/bin/sh
# This file is a part of Embedded HTTPS (https://github.com/kiler129/embedded-https)

PIDFILE="/var/run/embedded-https.pid"

if [ ! -f "$PIDFILE" ]; then
  echo "Embedded HTTPS is not running (no PIDFILE at ${PIDFILE})"
  exit 1
fi

SRVPID=$(cat "$PIDFILE")
if [ ! -d "/proc/$SRVPID" ]; then
  echo "Embedded HTTPS is not running (PID $SRVPID not active)"
  exit 1
fi

PARENTPID=$(awk '{ print $4 }' < "/proc/${SRVPID}/stat")
echo "Sending SIGHUP to ${PARENTPID} (parent of server $SRVPID)"
kill -SIGHUP "$PARENTPID"
