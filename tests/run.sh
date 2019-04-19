#!/bin/bash

set -e

echo "# tests with http and unverified https server"
rspec ./spec/insecure_spec.rb

echo "# installing local CA"
/root/.local/share/mkcert/mkcert -install

echo "# tests with verified https server"
rspec ./spec/secure_spec.rb
