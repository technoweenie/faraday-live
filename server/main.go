package main

import (
	"crypto/tls"
	"flag"
	"log"
	"net/http"
)

var (
	certFile = flag.String("cert-file", "", "File path to PEM encoded HTTPS certificate")
	keyFile  = flag.String("key-file", "", "File path to PEM encoded HTTPS key")
)

func main() {
	flag.Parse()

	httpServer := &http.Server{
		Addr:    ":80",
		Handler: newMux("http"),
	}
	if httpsNotConfigured() {
		log.Println("Starting Live HTTP server on port 80...")
		log.Fatal(httpServer.ListenAndServe())
		return
	}

	cert, err := tls.LoadX509KeyPair(*certFile, *keyFile)
	if err != nil {
		log.Fatal(err)
		return
	}

	log.Println("Starting Live HTTP server on port 80...")
	go httpServer.ListenAndServe()
	httpsServer := &http.Server{
		Addr:    ":443",
		Handler: newMux("https"),
		TLSConfig: &tls.Config{
			Certificates: []tls.Certificate{cert},
		},
	}
	log.Println("Starting Live HTTPS server on port 443...")
	log.Fatal(httpsServer.ListenAndServeTLS("", ""))
}

func newMux(kind string) *http.ServeMux {
	mux := http.NewServeMux()
	mux.HandleFunc("/requests/", Handle(kind, Requests))
	mux.HandleFunc("/multipart", Handle(kind, Multipart))
	return mux
}

func httpsNotConfigured() bool {
	if len(*certFile) == 0 {
		return true
	}
	if len(*keyFile) == 0 {
		return true
	}
	return false
}
