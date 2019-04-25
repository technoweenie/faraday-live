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
  end if ServerProtocols.proxy?

  describe "#{adapter} using HTTP proxy with HTTPS server" do
    include_examples 'a proxied connection', adapter, {
      proxy: :http_auth_proxy,
      server: :https,
      auth: "faraday:live",
    }
  end if ServerProtocols.proxy?
end
