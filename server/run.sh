#!/bin/sh

/root/.local/share/mkcert/mkcert -install
./server \
  -cert-file=/certs/faraday-live.localhost.pem \
  -key-file=/certs/faraday-live.localhost-key.pem
