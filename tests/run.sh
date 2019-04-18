#!/bin/bash

rspec ./spec/insecure_spec.rb
echo "installing local CA..."
/root/.local/share/mkcert/mkcert -install
rspec ./spec/secure_spec.rb
