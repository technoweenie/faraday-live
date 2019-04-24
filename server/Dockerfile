FROM golang:1.12.3
EXPOSE 80
EXPOSE 443

WORKDIR /app
COPY . ./
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o server .
CMD ./run.sh
