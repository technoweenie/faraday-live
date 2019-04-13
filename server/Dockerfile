FROM golang:1.12.3 AS build
WORKDIR /app
COPY ./* ./
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o server .

FROM alpine
WORKDIR /app
COPY --from=build /app/server /app/
COPY --from=build /app/run.sh /app/
EXPOSE 80
EXPOSE 443
CMD ./run.sh
