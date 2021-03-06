FROM golang:1.12.3
RUN go get -u github.com/FiloSottile/mkcert
ARG host=faraday-live.localhost

WORKDIR /root/.local/share/mkcert/
RUN mkcert -install
RUN cp $GOPATH/bin/mkcert /root/.local/share/mkcert/

WORKDIR /certs
COPY mkcert.sh .
RUN ./mkcert.sh $host
