#!/bin/sh

/root/.local/share/mkcert/mkcert -install
./server -http 80 -https 443 \
  -cert-file=/certs/faraday-live.localhost.pem \
  -key-file=/certs/faraday-live.localhost-key.pem
