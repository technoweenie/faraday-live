# frozen_string_literal: true

describe 'Faraday with HTTP server' do
  FaradayAdapters.each do |adapter|
    it_behaves_like 'a connection making requests',
      FaradayURLs.test_http_server, adapter
  end
end if ServerProtocols.http?


describe 'Faraday with unverified HTTPS server' do
  let(:base_url) { FaradayURLs.test_https_server }

  FaradayAdapters.each do |adapter|
    next if adapter.key == :typhoeus # https://github.com/technoweenie/faraday-live/issues/4
    next if adapter.key == :patron # https://github.com/technoweenie/faraday-live/issues/4

    context "using #{adapter}" do
      it "fails with verification enabled" do
        @conn = Faraday.new("#{base_url}/requests") do |conn|
          conn.request :url_encoded
          conn.adapter(adapter.key)
        end

        expect do
          conn.get('unverified_with_verification')
        end.to raise_error(Faraday::SSLError)
      end

      it "succeeds with verification disabled" do
        @conn = Faraday.new("#{base_url}/requests", ssl: { verify: false }) do |conn|
          conn.request :url_encoded
          conn.adapter(adapter.key)
        end

        res = conn.get('unverified_with_verification')
        expect(res.status).to eq(200)
      end
    end
  end
end if ServerProtocols.unverified_https?
