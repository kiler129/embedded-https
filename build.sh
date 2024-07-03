#!/bin/sh
set -e
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <arch>"
    exit 1
fi

BLD_ARCH="$1"
BLD_ARTIFACTS="$PWD/artifacts/ehttps-$BLD_ARCH"
BLD_PKG="$BLD_ARTIFACTS.tar.gz"
BLD_TSRP="/artifacts/tiny-ssl-reverse-proxy"

echo "Building for $1 arch"
mkdir "$BLD_ARTIFACTS"

docker run --rm \
  -e GOOS=linux -e GOARCH="$1" \
  -v "$PWD/include/tiny-ssl-reverse-proxy":/app:ro \
  -v "$BLD_ARTIFACTS":/artifacts \
  --workdir "/app" \
  golang:1.22-alpine \
  go build -v -tags netgo -ldflags '-w -s' -gcflags=all=-l -o "$BLD_TSRP"

echo "Build OK, creating package"
cp "$PWD/include/run-proxy.sh" "$BLD_ARTIFACTS/"
find "$BLD_ARTIFACTS" -type f -exec chmod +x {} +
tar -czvf "$BLD_PKG" -C "$(dirname "$BLD_ARTIFACTS")" "$(basename "$BLD_ARTIFACTS")"

echo "Cleaning up"
rm -rf "$BLD_ARTIFACTS"

echo "Package built to $BLD_PKG"
