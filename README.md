# Faraday Live

This is a multi-container application that performs live integration tests
with the ruby Faraday gem against a live web service with a valid HTTPS cert.

See also:

* [Build Process](./docs/build.md)
* [Development](./docs/dev.md)

## Usage

* Install Git, Docker, and Docker Compose.
* Clone https://github.com/technoweenie/faraday-live

```bash
$ docker-compose build
$ docker-compose run tests
```

## TODO

* Server
  * Endpoint for testing streaming requests and responses
  * Extract to separate project
