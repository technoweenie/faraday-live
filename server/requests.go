package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
)

func Requests(w http.ResponseWriter, r *http.Request, info *Request) (RequestInfo, error) {
	form, err := parseRequestBody(r)
	if err != nil {
		info.Error = fmt.Sprintf("error parsing request body as form: %+v", err)
	}

	info.Form = form
	return info, nil
}

func parseRequestBody(r *http.Request) (url.Values, error) {
	if r.Header.Get("Content-Type") == "application/json" {
		values := make(map[string][]string)
		err := json.NewDecoder(r.Body).Decode(&values)
		r.Body.Close()
		if err != nil {
			return url.Values{}, err
		}
		return url.Values(values), nil
	}

	err := r.ParseForm()
	r.Body.Close()
	if err != nil {
		return url.Values{}, err
	}
	return r.Form, nil
}
