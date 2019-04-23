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

	var err error
	w.Header().Set("Content-Type", "application/json")
	req.Form, err = parseRequestBody(r)
	if err != nil {
		w.WriteHeader(500)
		req.Error = fmt.Sprintf("error parsing request body as form: %+v", err)
	} else {
		w.WriteHeader(200)
	}

	started := r.Context().Value(ctxStarted).(time.Time)
	req.Duration = time.Now().Sub(started).String()
	if err := json.NewEncoder(w).Encode(req); err != nil {
		log.Printf("ERR: %+v", err)
	}
}

func parseRequestBody(r *http.Request) (url.Values, error) {
	if r.Header.Get("Content-Type") == "application/json" {
		values := make(map[string][]string)
		if err := json.NewDecoder(r.Body).Decode(&values); err != nil {
			return url.Values{}, err
		}
		return url.Values(values), nil
	}

	if err := r.ParseForm(); err != nil {
		return url.Values{}, err
	}
	return r.Form, nil
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
	Error            string
}
