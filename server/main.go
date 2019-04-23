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
	mpHandler := WithStarted(HandleMultipart)
	http.HandleFunc("/requests/", reqHandler)
	http.HandleFunc("/multipart", mpHandler)

	httpAddr := fmt.Sprintf(":%d", *httpPort)
	if httpsNotConfigured() {
		log.Printf("Starting Live HTTP server on port %d...", *httpPort)
		log.Fatal(http.ListenAndServe(httpAddr, nil))
		return
	}

	cert, err := tls.LoadX509KeyPair(*certFile, *keyFile)
	if err != nil {
		log.Fatal(err)
		return
	}

	log.Printf("Starting Live HTTP server on port %d...", *httpPort)
	go http.ListenAndServe(httpAddr, nil)
	server := &http.Server{
		Addr: fmt.Sprintf(":%d", *httpsPort),
		TLSConfig: &tls.Config{
			Certificates: []tls.Certificate{cert},
		},
	}
	log.Printf("Starting Live HTTPS server on port %d...", *httpsPort)
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
		now := time.Now()
		r2 := r.WithContext(
			context.WithValue(r.Context(), ctxStarted, now),
		)
		h(w, r2)
		log.Printf("%s %s %s [%s]",
			r.Method, r.RequestURI, r.UserAgent(), time.Since(now))
	}
}
