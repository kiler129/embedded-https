# Embedded HTTPS Proxy

Many medium-footprint embedded systems with web management. Unfortunately, most of them don't bother implementing HTTPS.
This is not only insecure, but often quite annoying given browsers' being stricter every day about HTTP pages (e.g. )

This project implements a small HTTPS => HTTP reverse proxy, based on [`tiny-ssl-reverse-proxy`](https://github.com/sensiblecodeio/tiny-ssl-reverse-proxy). It is pretty universal, but the main aim is to run on embedded systems with
low traffic needs.


## Structure
Originally, the project was motivated by the desire to add HTTPS support to [Valetudo](https://github.com/Hypfer/Valetudo)
to ensure passwords aren't sent in clear text, and password managers actually don't refuse to auto-fill them.

However, the usage isn't specific to Valetudo. Every release contains two files:
  - `tiny-ssl-reverse-proxy`: the proxy server
  - `run-proxy.sh`: bootstrap code for the proxy


## Usage
The proxy expects `cert.pem` and `key.pem` files to be present in the same directory as bootstrap code & proxy server.
If certificate and/or key are missing and OpenSSL is installed, a self-signed certificate will be generated.

To use the proxy simply run `run-proxy.sh`. You can set `EH_VERBOSE` to non-zero value to see log of requests.

### Usage with Valetudo
1. Unpack release (e.g. `tar -xzvf ehttps-arm64.tar.gz`)
2. (Optionally) Put `cert.pem` & `key.pem` in `ehttps-arm64`
3. Upload: `scp -O -r ehttps-arm64 root@my-vacuum:/data/`
4. Login via SSH and edit (e.g. with `nano`) the `/data/_root_postboot.sh` adding at the end:
```shell
/data/ehttps-arm64/run-proxy.sh > /dev/null 2>&1 &
```
5. `reboot` from the SSH session


## Building manually
If you don't want to use/don't trust releases on GitHub you can build your own package:

 - `./build.sh arm64`: builds aarch64 (ARM 64bit) binary
 - `./build.sh arm`: builds armv7 (ARM 32bit) binary
 - `./build.sh amd64`: builds x86-64 binary

The build script requires `docker` and should run on both Linux and macOS.
