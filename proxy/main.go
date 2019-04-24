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

	servers := &ServerList{}
	servers.Add(":8080", newProxy("http_proxy"))
	servers.AddWithTLS(":8443", newProxy("https_proxy"), *certFile, *keyFile)
	servers.Listen()
}

type ServerList struct {
	Servers    []*http.Server
	LastServer *http.Server
}

func (l *ServerList) Listen() {
	for _, srv := range l.Servers {
		go l.listen(srv)
	}

	if l.LastServer != nil {
		l.listen(l.LastServer)
	}
}

func (l *ServerList) listen(srv *http.Server) {
	log.Printf("Starting Proxy server on %s...", srv.Addr)
	if srv.TLSConfig == nil {
		srv.ListenAndServe()
		return
	}
	srv.ListenAndServeTLS("", "")
}

func (l *ServerList) Add(addr string, handler http.Handler) {
	l.add(&http.Server{
		Addr:    addr,
		Handler: handler,
	})
}

func (l *ServerList) AddWithTLS(addr string, handler http.Handler, certFile, keyFile string) {
	if len(certFile) == 0 || len(keyFile) == 0 {
		return
	}

	cert, err := tls.LoadX509KeyPair(certFile, keyFile)
	if err != nil {
		log.Fatal(err)
		return
	}

	l.add(&http.Server{
		Addr:    addr,
		Handler: handler,
		TLSConfig: &tls.Config{
			Certificates: []tls.Certificate{cert},
		},
	})
}

func (l *ServerList) add(s *http.Server) {
	if l.LastServer == nil {
		l.LastServer = s
		return
	}
	l.Servers = append(l.Servers, s)
}

func Servers(possibles ...*http.Server) []*http.Server {
	servers := make([]*http.Server, 0, len(possibles))
	for _, srv := range possibles {
		if srv != nil {
			servers = append(servers, srv)
		}
	}
	return servers
}
