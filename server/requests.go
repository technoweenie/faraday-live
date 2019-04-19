package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net"
	"net/http"
	"net/url"
	"time"
)

func HandleRequests(w http.ResponseWriter, r *http.Request) {
	if err := r.ParseForm(); err != nil {
		w.WriteHeader(500)
		fmt.Fprintf(w, "error parsing request body as form: %+v", err)
	}

	host := r.Host
	if shost, _, err := net.SplitHostPort(r.Host); err == nil {
		host = shost
	}

	req := Request{
		Method:           r.Method,
		Host:             host,
		RequestURI:       r.RequestURI,
		Header:           r.Header,
		TransferEncoding: r.TransferEncoding,
		Form:             r.Form,
		ContentLength:    r.ContentLength,
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(200)

	started := r.Context().Value(ctxStarted).(time.Time)
	req.Duration = time.Now().Sub(started).String()
	if err := json.NewEncoder(w).Encode(req); err != nil {
		log.Printf("ERR: %+v", err)
	}
}

type Request struct {
	Method           string
	Host             string
	RequestURI       string
	Header           http.Header
	ContentLength    int64
	TransferEncoding []string
	Form             url.Values
	Duration         string
}
