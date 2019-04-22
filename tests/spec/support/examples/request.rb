# frozen_string_literal: true

# Examples for ALL responses from the server
shared_examples 'any request' do |http_method|
  {
    'Content-Type' => 'application/json',
  }.each do |key, value|
    it "returns #{key} response header" do
      expect(response.headers[key]).to eq(value)
    end
  end

  it 'returns response status' do
    expect(response.status).to eq(200)
  end
end

# Examples for any requests expecting a response body from the server. Skipped
# for HEAD requests, and CONNECT requests for some specific adapters.
# See tests/spec/support/adapters.rb
shared_examples 'any request expecting a response body' do |http_method, adapter, options|
  options ||= {}

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
    expect(body['RequestURI']).to eq(options[:requesturi] || '/requests/test')
  end
end
