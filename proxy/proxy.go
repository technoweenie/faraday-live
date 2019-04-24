package main

import (
	"fmt"
	"net/http"

	"github.com/elazarl/goproxy"
)

func newProxy(kind string) http.Handler {
	proxy := goproxy.NewProxyHttpServer()
	proxy.Verbose = true
	proxy.OnRequest().DoFunc(
		func(r *http.Request, ctx *goproxy.ProxyCtx) (*http.Request, *http.Response) {
			r.Header.Set("Faraday-Proxy", fmt.Sprintf("goproxy (%s)", kind))
			return r, nil
		})

	proxy.OnResponse().DoFunc(
		func(r *http.Response, ctx *goproxy.ProxyCtx) *http.Response {
			r.Header.Set("Via", fmt.Sprintf("goproxy (%s)", kind))
			return r
		})
	return proxy
}
