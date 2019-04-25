package main

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"io"
	"net/http"
)

func Multipart(w http.ResponseWriter, r *http.Request, info *Request) (RequestInfo, error) {
	minfo := &MultipartRequest{Request: info}

	mpReader, err := r.MultipartReader()
	if err != nil {
		minfo.Error = fmt.Sprintf("error reading multipart data: %+v", err)
	} else {
		for {
			part, err := mpReader.NextPart()
			if err == io.EOF {
				break
			}

			if err != nil {
				minfo.Error = fmt.Sprintf("error reading multipart: %+v", err)
				break
			}

			h := sha256.New()
			w, err := io.Copy(h, part)
			if err != nil {
				minfo.Error = fmt.Sprintf("error reading multipart: %+v", err)
				break
			}

			parthead := make(map[string]string, len(part.Header))
			for key := range part.Header {
				parthead[key] = part.Header.Get(key)
			}
			minfo.FormParts = append(minfo.FormParts, FormPart{
				FormName:      part.FormName(),
				FileName:      part.FileName(),
				Size:          w,
				BodySignature: hex.EncodeToString(h.Sum(nil)),
				Header:        parthead,
			})
		}
	}

	r.Body.Close()
	return minfo, nil
}

type FormPart struct {
	FormName      string
	FileName      string
	Size          int64
	BodySignature string
	Header        map[string]string
}

type MultipartRequest struct {
	*Request
	FormParts []FormPart
}
