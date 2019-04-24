package main

import (
	"fmt"
	"log"
	"net/http"
	"regexp"

	"github.com/elazarl/goproxy"
	"github.com/elazarl/goproxy/ext/auth"
)

func newProxy(kind string) http.Handler {
	proxy := goproxy.NewProxyHttpServer()
	proxy.Verbose = true

	if reAuth.MatchString(kind) {
		log.Println("setting up auth")
		auth.ProxyBasic(proxy, "faraday_live", func(user, passwd string) bool {
			return user == "faraday" && passwd == "live"
		})
	}

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

var reAuth = regexp.MustCompile("auth")
