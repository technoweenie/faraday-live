#!/bin/sh

/root/.local/share/mkcert/mkcert -install
./proxy \
  -cert-file=/certs/live-proxy.localhost.pem \
  -key-file=/certs/live-proxy.localhost-key.pem
