package main

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"time"
)

func HandleMultipart(w http.ResponseWriter, r *http.Request) {
	host := r.Host
	if shost, _, err := net.SplitHostPort(r.Host); err == nil {
		host = shost
	}

	req := MultipartRequest{
		Request: Request{
			Method:           r.Method,
			Host:             host,
			RequestURI:       r.RequestURI,
			Header:           r.Header,
			TransferEncoding: r.TransferEncoding,
			Form:             r.Form,
			ContentLength:    r.ContentLength,
		},
	}

	w.Header().Set("Content-Type", "application/json")

	mpReader, err := r.MultipartReader()
	if err != nil {
		req.Error = fmt.Sprintf("error reading multipart data: %+v", err)
	} else {
		for {
			part, err := mpReader.NextPart()
			if err == io.EOF {
				break
			}

			if err != nil {
				req.Error = fmt.Sprintf("error reading multipart: %+v", err)
				break
			}

			h := sha256.New()
			w, err := io.Copy(h, part)
			if err != nil {
				req.Error = fmt.Sprintf("error reading multipart: %+v", err)
				break
			}

			parthead := make(map[string]string, len(part.Header))
			for key := range part.Header {
				parthead[key] = part.Header.Get(key)
			}
			req.FormParts = append(req.FormParts, FormPart{
				FormName:      part.FormName(),
				FileName:      part.FileName(),
				Size:          w,
				BodySignature: hex.EncodeToString(h.Sum(nil)),
				Header:        parthead,
			})
		}
	}

	if len(req.Error) == 0 {
		w.WriteHeader(200)
	} else {
		w.WriteHeader(500)
	}

	started := r.Context().Value(ctxStarted).(time.Time)
	req.Duration = time.Now().Sub(started).String()
	if err := json.NewEncoder(w).Encode(req); err != nil {
		log.Printf("ERR: %+v", err)
	}
}

type FormPart struct {
	FormName      string
	FileName      string
	Size          int64
	BodySignature string
	Header        map[string]string
}

type MultipartRequest struct {
	Request
	FormParts []FormPart
}
