#!/bin/sh
# This file is a part of Embedded HTTPS (https://github.com/kiler129/embedded-https)

PIDFILE=/var/run/embedded-https.pid
SCRDIR=$(cd -- "$(dirname -- "$0")" && pwd)
CERTFILE="$SCRDIR/cert.pem"
KEYFILE="$SCRDIR/key.pem"

cleanup () {
  if [ -f "$PIDFILE" ]; then
    echo "Embedded HTTPS proxy finished"
    rm "$PIDFILE"
  fi
}

ensure_cert () {
  if [ -f "$CERTFILE" ] && [ -f "$KEYFILE" ]; then
    return 0
  fi

  echo "Warning: SSL certificate ($CERTFILE) or its key ($KEYFILE) doesn't exist; attempting to generate..."
  if ! command -v openssl > /dev/null 2>&1
  then
    echo "Failed to generate self-signed certificate - OpenSSL not found"
    echo "Please provider proper certificate ($CERTFILE) with key ($KEYFILE)"
    exit 1
  fi

  SSL_HOST=$(uname -n)
  openssl req -x509 \
    -newkey rsa:2048 -keyout "$KEYFILE" \
    -out "$CERTFILE" \
    -sha256 -days 365 -nodes \
    -subj "/C=WW/ST=/L=/O=$SSL_HOST/OU=/CN=$SSL_HOST" \
    -addext "subjectAltName=DNS:$SSL_HOST"
}

if [ -f "$PIDFILE" ]; then
  OLDPID=$(cat "$PIDFILE")
  if [ -d "/proc/$OLDPID" ]; then
    echo "Embedded HTTPS is already running (PID: $OLDPID)"
    exit 1
  else
    echo "Embedded HTTPS old process remains found - it most likely crashed, restarting..."
  fi
fi

echo $$ > "$PIDFILE"
if [ $? -ne 0 ]; then
  echo "Failed to save PID to $PIDFILE"
  exit 1
fi
trap cleanup INT TERM HUP EXIT

echo "Starting Embedded HTTPS (PID: $$)"
ensure_cert

if [ -n "$EH_VERBOSE" ] && [ "$EH_VERBOSE" -eq "$EH_VERBOSE" ] 2>/dev/null && [ "$EH_VERBOSE" -ne 0 ]; then
  echo "Verbose mode enabled"
  "$SCRDIR/tiny-ssl-reverse-proxy" \
    -cert "$SCRDIR/cert.pem" \
    -key "$SCRDIR/key.pem" \
    -logging=true
else
  echo "Verbose mode disabled"
  "$SCRDIR/tiny-ssl-reverse-proxy" \
    -cert "$SCRDIR/cert.pem" \
    -key "$SCRDIR/key.pem" \
    -logging=false > /dev/null 2>&1
fi
