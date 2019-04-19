# frozen_string_literal: true

shared_examples 'a connection making requests' do |base_url, adapter|
  let(:conn) do
    conn_options = {
      headers: {
        'X-Faraday-Live' => '1',
        user_agent: "Faraday: #{adapter}",
      },
    }

    Faraday.new("#{base_url}/requests", conn_options) do |conn|
      conn.request :url_encoded
      conn.adapter(adapter.key)
    end
  end

  let(:body) do
    begin
      JSON.parse(response.body)
    rescue JSON::ParserError
      puts response.body
      raise
    end
  end

  describe "with #{adapter}: #CONNECT" do
    it_behaves_like 'an idempotent request', :connect, adapter
  end if FaradayMethods.connect_method?(adapter)

  describe "with #{adapter}: #DELETE" do
    it_behaves_like 'an idempotent request', :delete, adapter
    it_behaves_like 'a json request', :delete, adapter
  end if FaradayMethods.delete_method?(adapter)

  describe "with #{adapter}: #GET" do
    it_behaves_like 'an idempotent request', :get, adapter
    it_behaves_like 'a json request', :get, adapter
  end if FaradayMethods.get_method?(adapter)

  describe "with #{adapter}: #HEAD" do
    let(:response) do
      conn.head('test')
    end

    include_examples 'any request', :head

    it 'receives empty response body' do
      expect(response.headers[:content_length].to_i).to be > 0
      expect(response.body).to eq('')
    end
  end if FaradayMethods.head_method?(adapter)

  describe "with #{adapter}: #OPTIONS" do
    it_behaves_like 'an idempotent request', :options, adapter
  end if FaradayMethods.options_method?(adapter)

  describe "with #{adapter}: #PATCH" do
    it_behaves_like 'a form post request', :patch, adapter
  end if FaradayMethods.patch_method?(adapter)

  describe "with #{adapter}: #POST" do
    it_behaves_like 'a form post request', :post, adapter
  end if FaradayMethods.post_method?(adapter)

  describe "with #{adapter}: #PUT" do
    it_behaves_like 'a form post request', :put, adapter
  end if FaradayMethods.put_method?(adapter)

  describe "with #{adapter}: #TRACE" do
    it_behaves_like 'an idempotent request', :trace, adapter
  end if FaradayMethods.trace_method?(adapter)
end

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

shared_examples 'a form post request' do |http_method, adapter|
  let(:response) do
    conn.public_send(http_method, 'test') do |req|
      req.body = {request_param: 'faraday live'}
    end
  end

  include_examples 'any request', http_method

  it 'sends form content' do
    expect(body['Header']['Content-Type']).to eq(["application/x-www-form-urlencoded"])
  end

  it 'sends request body' do
    expect(body['ContentLength']).to eq(26)
    expect(body['Form']['request_param']).to eq(['faraday live']),
      "got: #{body['Form'].inspect}"
  end
end

shared_examples 'a json request' do |http_method, adapter|
  let(:response) do
    conn.public_send(http_method, 'test') do |req|
      req.headers[:content_type] = 'application/json'
      req.body = {request_param: ['faraday live']}.to_json
    end
  end

  include_examples 'any request', http_method

  it 'sends form content' do
    expect(body['Header']['Content-Type']).to eq(["application/json"])
  end

  it 'sends request body' do
    expect(body['ContentLength']).to eq(34)
    expect(body['Form']['request_param']).to eq(['faraday live']),
      "got: #{body['Form'].inspect}"
  end
end

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
