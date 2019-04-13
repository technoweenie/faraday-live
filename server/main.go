package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"net/http"
	"time"
)

var port = flag.Int("port", 8080, "Network port for the HTTP server.")

func main() {
	flag.Parse()
	reqHandler := WithStarted(HandleRequests)
	http.HandleFunc("/requests", reqHandler)
	http.HandleFunc("/requests/", reqHandler)

	log.Printf("Starting echo server on port %d...", *port)

	bind := fmt.Sprintf(":%d", *port)
	log.Fatal(http.ListenAndServe(bind, nil))
}

type ctxkey int

const ctxStarted = ctxkey(1)

func WithStarted(h http.HandlerFunc) func(http.ResponseWriter, *http.Request) {
	return func(w http.ResponseWriter, r *http.Request) {
		r2 := r.WithContext(
			context.WithValue(r.Context(), ctxStarted, time.Now()),
		)
		h(w, r2)
	}
}
