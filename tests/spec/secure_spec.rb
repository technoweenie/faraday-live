# frozen_string_literal: true

FaradayAdapters.each do |adapter|
  describe "#{adapter} with HTTPS server" do
    include_examples 'a connection making requests', :https, adapter
  end if ServerProtocols.https?

  describe "#{adapter} using HTTP proxy with HTTPS server" do
    include_examples 'a proxied connection', adapter, {
      proxy: :http_proxy,
      server: :https,
    }
  end if ServerProtocols.http_proxy?

  describe "#{adapter} using authenticated HTTP proxy with HTTPS server" do
    include_examples 'a proxied connection', adapter, {
      proxy: :http_auth_proxy,
      server: :https,
      auth: "faraday:live",
    }
  end if ServerProtocols.http_proxy?

  describe "#{adapter} using Socks proxy with HTTPS server" do
    include_examples 'a proxied connection', adapter, {
      proxy: :socks_proxy,
      server: :https,
    }
  end if ServerProtocols.socks_proxy? && adapter.socks_proxy?

  describe "#{adapter} using authenticated Socks proxy with HTTPS server" do
    include_examples 'a proxied connection', adapter, {
      proxy: :socks_auth_proxy,
      server: :https,
      auth: "faraday:live",
    }
  end if ServerProtocols.socks_proxy? && adapter.socks_proxy?

  describe "#{adapter} using HTTPS proxy with HTTPS server" do
    it "fails to connect" do
      reqs_url = FaradayURLs.server(:https, "requests")
      proxy_url = FaradayURLs.server(:https_proxy)
      conn = Faraday.new(reqs_url, proxy: proxy_url) do |conn|
        conn.adapter(adapter.key)
      end
      expect { conn.get 'wat' }.to raise_error(Faraday::ConnectionFailed)
    end
  end if ServerProtocols.http_proxy? && !adapter.https_proxy_bug?

  describe "#{adapter} using authenticated HTTPS proxy with HTTPS server" do
    it "fails to connect" do
      reqs_url = FaradayURLs.server(:https, "requests")
      proxy_url = FaradayURLs.server(:https_auth_proxy, 'faraday:live')
      conn = Faraday.new(reqs_url, proxy: proxy_url) do |conn|
        conn.adapter(adapter.key)
      end
      expect { conn.get 'wat' }.to raise_error(Faraday::ConnectionFailed)
    end
  end if ServerProtocols.http_proxy? && !adapter.https_proxy_bug?
end
