#!/bin/bash

ruby ./lib/insecure.rb
/root/.local/share/mkcert/mkcert -install
ruby ./lib/run.rb
