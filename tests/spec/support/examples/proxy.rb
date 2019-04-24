# frozen_string_literal: true

shared_examples 'a proxied connection' do |adapter, options|
  options ||= {}
  server_url_kind = options[:server]
  raise "no :server url option" if server_url_kind.to_s.empty?

  before :all do
    conn_options = {
      headers: {
        'X-Faraday-Live' => '1',
        user_agent: "Faraday: #{adapter}",
      },
      proxy: FaradayURLs.test_server(:proxy),
    }

    reqs_url = FaradayURLs.test_server(server_url_kind, "requests")
    @conn = Faraday.new(reqs_url, conn_options) do |conn|
      conn.request :multipart
      conn.request :url_encoded
      conn.adapter(adapter.key)
    end
  end

  include_examples 'common request tests', server_url_kind, adapter,
    response_header: {
      # proxy does not modify https requests
      'Via' => server_url_kind == :https ? '' : /goproxy/,
    },
    request_header: {
      'Faraday-Proxy' => server_url_kind == :https ? '' : /goproxy/,
    }
end
