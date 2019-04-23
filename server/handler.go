package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"net/url"
	"time"
)

type InfoHandler func(http.ResponseWriter, *http.Request, *Request) (RequestInfo, error)

type Request struct {
	Method           string
	Host             string
	RequestURI       string
	Header           http.Header
	ContentLength    int64
	TransferEncoding []string
	Form             url.Values
	Duration         string
	Error            string
}

func (r *Request) OrigRequest() *Request {
	return r
}

type RequestInfo interface {
	OrigRequest() *Request
}

func Handle(kind string, infohandler InfoHandler) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		now := time.Now()
		host := r.Host
		if shost, _, err := net.SplitHostPort(r.Host); err == nil {
			host = shost
		}

		info := &Request{
			Method:           r.Method,
			Host:             host,
			RequestURI:       r.RequestURI,
			Header:           r.Header,
			TransferEncoding: r.TransferEncoding,
			Form:             r.Form,
			ContentLength:    r.ContentLength,
		}

		head := w.Header()
		head.Set("Content-Type", "application/json")
		head.Set("Server", fmt.Sprintf("Faraday Live (%s)", kind))

		info2, err := infohandler(w, r, info)
		if err != nil {
			log.Printf("ERR running handler: %+v", err)
		}
		finalinfo := info2.OrigRequest()
		finalinfo.Duration = time.Now().Sub(now).String()

		buf := &bytes.Buffer{}
		writers := io.MultiWriter(w, buf)

		if err := json.NewEncoder(writers).Encode(info2); err != nil {
			log.Printf("ERR encoding JSON: %+v", err)
		}

		log.Printf("%s %s %s [%s]",
			r.Method, r.RequestURI, r.UserAgent(), time.Since(now))
		log.Printf("RESP: %+v", buf.String())
	}
}
