FROM golang:1.12.3
RUN go get -u github.com/FiloSottile/mkcert

WORKDIR /root/.local/share/mkcert/
RUN mkcert -install
RUN cp $GOPATH/bin/mkcert /root/.local/share/mkcert/

WORKDIR /certs
RUN mkcert faraday-live.localhost
RUN ls -al
