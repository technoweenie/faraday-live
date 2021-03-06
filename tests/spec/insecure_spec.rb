# frozen_string_literal: true

FaradayAdapters.each do |adapter|
  describe "#{adapter} with HTTP server" do
    include_examples 'a connection making requests', :http, adapter
  end if ServerProtocols.http?

  describe "#{adapter} using HTTP proxy with HTTP server" do
    include_examples 'a proxied connection', adapter, {
      proxy: :http_proxy,
      server: :http,
    }
  end if ServerProtocols.http_proxy?

  describe "#{adapter} using Socks proxy with HTTP server" do
    include_examples 'a proxied connection', adapter, {
      proxy: :socks_proxy,
      server: :http,
    }
  end if ServerProtocols.socks_proxy? && adapter.socks_proxy?

  describe "#{adapter} using authenticated HTTP proxy with HTTP server" do
    include_examples 'a proxied connection', adapter, {
      proxy: :http_auth_proxy,
      server: :http,
      auth: "faraday:live",
    }
  end if ServerProtocols.http_proxy?

  describe "#{adapter} using authenticated Socks proxy with HTTP server" do
    include_examples 'a proxied connection', adapter, {
      proxy: :socks_auth_proxy,
      server: :http,
      auth: "faraday:live",
    }
  end if ServerProtocols.socks_proxy? && adapter.socks_proxy?

  describe "#{adapter} with unverified HTTPS server" do
    let(:url_kind) { :https }

    it "fails with verification enabled" do
      @conn = Faraday.new(requests_url) do |conn|
        conn.request :url_encoded
        conn.adapter(adapter.key)
      end

      expect do
        conn.get('unverified_with_verification')
      end.to raise_error(Faraday::SSLError)
    end

    it "succeeds with verification disabled" do
      @conn = Faraday.new(requests_url, ssl: { verify: false }) do |conn|
        conn.request :url_encoded
        conn.adapter(adapter.key)
      end

      res = conn.get('unverified_with_verification')
      expect(res.status).to eq(200)
    end
  end if ServerProtocols.unverified_https? && !adapter.unverified_https_bug?
end
