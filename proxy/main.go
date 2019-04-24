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
		Addr:    ":8080",
		Handler: newProxy("http"),
	}
	if httpsNotConfigured() {
		log.Println("Starting Live HTTP server on port 8080...")
		log.Fatal(httpServer.ListenAndServe())
		return
	}

	cert, err := tls.LoadX509KeyPair(*certFile, *keyFile)
	if err != nil {
		log.Fatal(err)
		return
	}

	log.Println("Starting Live HTTP server on port 8080...")
	go httpServer.ListenAndServe()
	httpsServer := &http.Server{
		Addr:    ":8443",
		Handler: newProxy("https"),
		TLSConfig: &tls.Config{
			Certificates: []tls.Certificate{cert},
		},
	}
	log.Println("Starting Live HTTPS server on port 8443...")
	log.Fatal(httpsServer.ListenAndServeTLS("", ""))
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
