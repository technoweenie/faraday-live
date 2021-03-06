# Faraday Live Build Process

This application is made up three docker containers assembled with [Docker
Compose][dc].

## MKCert Service

The [MKCert Container](../Dockerfile) simply installs mkcert and generates PEM
encoded certificate and key files for the server. [Docker Compose][dc] sets up
volumes to share the Root CA and web server PEM files with the other docker
containers.

## Proxy Service

The [Proxy Container](../proxy/Dockerfile) compiles and runs the custom Faraday
Live proxy server.

## Server Service

The [Server Container](../server/Dockerfile) compiles and runs the Faraday Live
server. [Docker Compose][dc] uses the mkcert container's volumes to access the
web server PEM files. A Docker volume for just the `server/run.sh` script is set
up to ease [development][dev].

## Tests Service

The [Tests Container](../tests/Dockerfile) loads all of the gems necessary to
test Faraday. [Docker Compose][dc] uses the mkcert container's volumes to
install the Root CA. Docker volumes for `tests/run.sh` and `tests/lib` (which
contains all the ruby scripts) are set up to ease [development][dev].

The Tests Container runs the following:

* `rspec spec/insecure.rb` to test against the HTTPS server before the Root CA
has been installed.
* `mkcert -install`
* `rspec spec/run.rb` runs all of the other tests.

[dc]: ../docker-compose.yml
[dev]: ./dev.md
