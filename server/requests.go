package main

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"time"
)

func HandleRequests(w http.ResponseWriter, r *http.Request) {
	bodySize, bodySHA, bodyErr := ScanBody(r.Body)
	if bodyErr != nil {
		w.WriteHeader(500)
		fmt.Fprintf(w, "error reading body: %+v", bodyErr)
	}

	req := Request{
		Method:           r.Method,
		Host:             r.Host,
		RequestURI:       r.RequestURI,
		Header:           r.Header,
		TransferEncoding: r.TransferEncoding,
		Form:             r.Form,
		ContentLength:    bodySize,
	}

	if bodySize > 0 {
		req.BodySignature = &bodySHA
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
	BodySignature    *string
	TransferEncoding []string
	Form             url.Values
	Duration         string
}

func ScanBody(rc io.ReadCloser) (int64, string, error) {
	h := sha256.New()
	n, err := io.Copy(h, rc)
	rc.Close()
	return n, hex.EncodeToString(h.Sum(nil)), err
}
