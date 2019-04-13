FROM golang:1.12.3
WORKDIR /app
COPY . ./
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o server .
EXPOSE 80
EXPOSE 443
CMD ./run.sh
