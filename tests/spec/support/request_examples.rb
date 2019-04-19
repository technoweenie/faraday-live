# frozen_string_literal: true

shared_examples 'a connection making requests' do |base_url, adapter|
  let(:conn) do
    conn_options = {
      headers: {
        'X-Faraday-Live' => '1',
        user_agent: 'Faraday Live Client',
      },
    }

    Faraday.new("#{base_url}/requests", conn_options) do |conn|
      conn.request :url_encoded
      conn.adapter(adapter)
    end
  end

  context "with #{adapter}:" do
    describe '#DELETE' do
      it_behaves_like 'an idempotent request', :delete
    end

    describe '#GET' do
      it_behaves_like 'an idempotent request', :get
    end

    describe '#HEAD' do
      include_examples 'any request', :head
      it 'receives empty response body' do
        expect(response.headers[:content_length].to_i).to be > 0
        expect(response.body).to eq('')
      end
    end
  end
end

shared_examples 'an idempotent request' do |http_method|
  include_examples 'any request', http_method
  include_examples 'any request expecting a response body', http_method


  it 'sends no body' do
    expect(body['ContentLength']).to eq(0)
    expect(body['BodySignature']).to be_nil
  end

  it 'sends no form' do
    expect(body['Form']).to be_nil
  end
end

shared_examples 'any request' do |http_method|
  let(:response) do
    conn.public_send(http_method, 'test')
  end

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

shared_examples 'any request expecting a response body' do |http_method|
  let(:body) { JSON.parse(response.body) }

  {
    'User-Agent' => 'Faraday Live Client',
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
