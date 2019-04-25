#!/bin/bash

for var in "$@"
do
  `mkcert $var`
done
