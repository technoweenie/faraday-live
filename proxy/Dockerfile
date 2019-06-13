FROM golang:1.12.3
RUN go get -u github.com/elazarl/goproxy
RUN go get -u github.com/armon/go-socks5

# no auth, http
EXPOSE 8080

# no auth, https
EXPOSE 8443

# auth:pass, http
EXPOSE 9080

# auth:pass, https
EXPOSE 9080

# no auth, socks
EXPOSE 6000

# auth:pass, socks
EXPOSE 6001

WORKDIR /app
COPY . ./
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o proxy .
CMD ./run.sh
