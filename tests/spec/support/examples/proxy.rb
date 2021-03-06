# frozen_string_literal: true

shared_examples 'a proxied connection' do |adapter, options|
  options ||= {}
  proxy_url_kind = options[:proxy]
  server_url_kind = options[:server]
  raise "no :proxy url option" if proxy_url_kind.to_s.empty?
  raise "no :server url option" if server_url_kind.to_s.empty?

  before :all do
    conn_options = {
      headers: {
        'X-Faraday-Live' => '1',
        user_agent: "Faraday: #{adapter}",
      },
      proxy: FaradayURLs.server(proxy_url_kind, options[:auth]),
    }

    reqs_url = FaradayURLs.server(server_url_kind, "requests")
    @conn = Faraday.new(reqs_url, conn_options) do |conn|
      conn.request :multipart
      conn.request :url_encoded
      conn.adapter(adapter.key)
    end
  end

  # proxy does not modify https requests
  expected = case proxy_url_kind
  when :socks_proxy, :socks_auth_proxy
    ""
  else
    server_url_kind == :https ? "" : "goproxy (#{proxy_url_kind})"
  end
  include_examples 'common request tests', server_url_kind, adapter,
    response_header: {
      'Via' => expected,
    },
    request_header: {
      'Faraday-Proxy' => expected,
    },
    proxy: options[:proxy]
end
