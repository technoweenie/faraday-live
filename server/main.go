package main

import (
	"context"
	"crypto/tls"
	"flag"
	"fmt"
	"log"
	"net/http"
	"time"
)

var (
	httpPort  = flag.Int("http", 8080, "Network port for the HTTP server.")
	httpsPort = flag.Int("https", 8081, "Network port for the HTTPS server.")
	certFile  = flag.String("cert-file", "", "File path to PEM encoded HTTPS certificate")
	keyFile   = flag.String("key-file", "", "File path to PEM encoded HTTPS key")
)

func main() {
	flag.Parse()
	reqHandler := WithStarted(HandleRequests)
	http.HandleFunc("/requests", reqHandler)
	http.HandleFunc("/requests/", reqHandler)

	log.Printf("Starting Live server on port %d...", *httpPort)

	httpAddr := fmt.Sprintf(":%d", *httpPort)
	if httpsNotConfigured() {
		log.Fatal(http.ListenAndServe(httpAddr, nil))
		return
	}

	cert, err := tls.LoadX509KeyPair(*certFile, *keyFile)
	if err != nil {
		log.Fatal(err)
		return
	}

	go http.ListenAndServe(httpAddr, nil)
	server := &http.Server{
		Addr: fmt.Sprintf(":%d", *httpsPort),
		TLSConfig: &tls.Config{
			Certificates: []tls.Certificate{cert},
		},
	}
	log.Fatal(server.ListenAndServeTLS("", ""))
}

func httpsNotConfigured() bool {
	if *httpsPort < 1 {
		return true
	}
	if len(*certFile) == 0 {
		return true
	}
	if len(*keyFile) == 0 {
		return true
	}
	return false
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
