# frozen_string_literal: true

# runs tests for an adapter and http method with no request body
shared_examples 'an idempotent request' do |http_method, adapter|
  let(:response) do
    conn.public_send(http_method, 'test')
  end

  include_examples 'any request', http_method

  if http_method != :connect || adapter.connect_with_response_body?
    include_examples 'any request expecting a response body', http_method, adapter

    it 'sends no body' do
      expect(body['ContentLength']).to eq(0)
      expect(body['Form']).to eq({})
    end
  end
end

# Examples for idempotent requests expecting a response body from the server.
# Skipped for HEAD requests, and CONNECT requests for some specific adapters.
# See tests/spec/support/adapters.rb
shared_examples 'any request expecting a response body' do |http_method, adapter|
  {
    'User-Agent' => "Faraday: #{adapter.key}",
    'X-Faraday-Live' => '1',
  }.each do |key, value|
    it "sends #{key} request header" do
      ua = body['Header'][key]
      expect(ua[0].to_s).to eq(value)
      expect(ua.size).to eq(1)
    end
  end

  it 'receives a response body' do
    expect(response.headers[:content_length].to_i).to be > 0
  end

  it 'uses valid method' do
    expect(body['Method']).to eq(http_method.to_s.upcase)
  end

  it 'accesses correct host' do
    expect(body['Host']).to eq(ENV['HTTP_HOST'])
  end

  it 'crafts correct request uri' do
    expect(body['RequestURI']).to eq('/requests/test')
  end
end
