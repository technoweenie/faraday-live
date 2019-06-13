# Faraday Live Development

## Initial Setup

Simply run `docker-compose build` in the root directory of this repository. This
will take some time the first time. Future runs take advantage of any local
docker images that exist.

```bash
$ docker-compose build
```

You can also build one of the three services individually:

* `docker-compose build mkcert`
* `docker-compose build server`
* `docker-compose build tests`

## Running Tests

Once fully setup, you can simply run the `tests` service:

```bash
$ docker-compose run tests
Creating network "faraday-live_default" with the default driver
Creating network "faraday-live_net" with the default driver
Creating volume "faraday-live_certca" with default driver
Creating volume "faraday-live_certdata" with default driver
Creating faraday-live_mkcert_1 ... done
Creating faraday-live_server_1 ... done
...
```

### Choosing Tests

This runs tests against these webservers and proxies:

1. HTTP server on port 80 (`TEST_PROTO=http`)
2. Self-signed HTTPS server on port 443 (`TEST_PROTO=unverified`)
3. Verified and valid HTTPS server on port 443 (`TEST_PROTO=https`)
4. HTTP proxy server (`TEST_PROTO=http_proxy`)
5. SOCKS proxy server (`TEST_PROTO=socks_proxy`)
6. Both HTTP and SOCKS proxy servers (`TEST_PROTO=proxy`)

You can choose to run one or more explicitly:

```bash
# test just one adapter
$ TEST_PROTO=http docker-compose run tests

# separate multiple adapters with a comma
$ TEST_PROTO=unverified,https docker-compose run tests
```

You can also specify which adapters to test:

```bash
# test just one adapter
$ TEST_ADAPTER=net_http docker-compose run tests

# separate multiple adapters with a comma
$ TEST_ADAPTER=net_http,excon docker-compose run tests
```

Finally, you can specify the http methods to test:

```bash
$ TEST_METHOD=get,head docker-compose run tests

# mix and match to your heart's content
$ TEST_PROTO=https TEST_ADAPTER=net_http TEST_METHOD=put docker-compose run tests
```

### Troubleshooting

You can see the running live server in Docker:

```bash
$ docker ps
CONTAINER ID        IMAGE                 COMMAND                 CREATED             STATUS              PORTS               NAMES
7d57533dcc45        faraday-live_server   "/bin/sh -c ./run.sh"   2 minutes ago       Up 2 minutes        80/tcp, 443/tcp     faraday-live_server_1

# stop any running Faraday Live containers and docker networks.
$ docker-compose down
Stopping faraday-live_server_1 ... done
Removing faraday-live_tests_run_a6d91855bef7 ... done
Removing faraday-live_tests_run_baeb89a750df ... done
Removing faraday-live_tests_run_fa9210c0a5e0 ... done
Removing faraday-live_tests_run_b48fc7c36dd1 ... done
Removing faraday-live_server_1               ... done
Removing faraday-live_mkcert_1               ... done
Removing network faraday-live_default
Removing network faraday-live_net

$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```

Note: If the tests are run while the `server` service is down, the initial
tests may raise a TCP connection error. This is because the `tests` service is
running before the `server` service has finished starting up. You can fix this
ahead of time by starting the `server` service manually.

```bash
$ docker-compose up -d server # only needed once
$ docker-compose run tests
# ...
$ docker-compose down # kill any running containers when you're done
```

If you want to see the server output, you can also run it manually in another
terminal:

```bash
$ docker-compose up server
# CTRL+C to shut down gracefully
```

## Updating the Server service

Any changes to the Server service require any running containers to be shut
down:

```bash
$ docker-compose down
```

Any changes to any `*.go` files under `./server` require compilation:

```bash
$ docker-compose down
$ docker-compose build server
```

### Troubleshooting

Start the server service, with STDOUT/STDERR redirected to the foreground shell:

```bash
$ docker-compose run server
```

Run `bash` on the server.

```bash
$ docker-compose run server bash
```

Note: This does _not_ setup the mkcert root CA, since it skips
`./server/run.sh`.

## Updating the Tests service

Any changes to `./tests/run.sh` or any files in `./test/lib` will be reflected
in each test run:

```bash
$ docker-compose run tests
```

You can run `bash` in the container if you have problems:

```bash
$ docker-compose run tests bash
```

Note: This does _not_ setup the mkcert root CA, since it skips
`./tests/run.sh`. You'll need to run the same `path/to/mkcert -install` command
if you want the server's HTTPS certificate to validate.

## Cleanup

Docker and Docker Compose tend to leave a lot of images and containers around.
Here's how you can remove all traces of Faraday Live:

```bash
# * shuts down containers
# * removes docker networks
# * removes any docker images
# * remove named docker volumes
# * remove orphan containers
$ docker-compose down --rmi all -v --remove-orphans
```

There may still be a dangling docker image. You can confirm and optionally
remove it:

```bash
# list all docker images
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
<none>              <none>              50bac947e076        8 minutes ago       807MB
alpine              latest              cdf98d1859c1        3 days ago          5.53MB
golang              1.12.3              1d14d4efd0a2        4 days ago          774MB
ruby                2                   8d6721e9290e        2 weeks ago         870MB
ruby                2.6.2               8d6721e9290e        2 weeks ago         870MB
golang              1.10.3              4e611157870f        9 months ago        794MB
ruby                2.3.4               4d9cdd30c445        19 months ago       735MB
iron/go             latest              25e73fd3c659        2 years ago         7.58MB

# list just the dangling ones
$ docker images -f dangling=true
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
<none>              <none>              50bac947e076        9 minutes ago       807MB

# list the dangling images' IDs
$ docker images -f dangling=true -q
50bac947e076

# remove all dangling images
$ docker rmi $(docker images -f dangling=true -q)

# optional: remove a named image
$ docker rmi golang:1.12.3
```

Be careful, this can affect any other docker applications you're working with.
However, you should be able to get back up to speed by running any affected
projects' build scripts. For Faraday Live, just run `docker-compose build`.
